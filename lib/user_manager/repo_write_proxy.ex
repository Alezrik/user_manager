defmodule UserManager.RepoWriteProxy do
  @moduledoc false
  use GenServer
  alias UserManager.Repo
  alias UserManager.Schemas.UserSchema
  import Ecto.Query
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def insert_user(user_changeset) do
    GenServer.call(UserManager.RepoWriteProxy, {:insert_user, user_changeset})
  end
  def update_user_profile(user_profile_changeset) do
    GenServer.call(UserManager.RepoWriteProxy, {:update_user_profile, user_profile_changeset})
  end
  def update_permission(permission_update, user) do
    GenServer.call(UserManager.RepoWriteProxy, {:update_permission, permission_update, user})
  end
  def handle_call({:update_permission, permission_update, user}, _from, state) do
    response = case Repo.update(permission_update) do
          {:ok, update_permission} ->
            u = UserSchema
            |> where(id: ^user.id)
            |> Repo.one!
            Task.await(Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
            UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, :update, %{"user" => u}, %UserManager.Struct.Notification{destination_pid: self()})
            receive do
              m -> m
            end
            end))
            {:ok, update_permission}
          {:error, ch} -> {:error, ch}
    end
    {:reply, response, state}
  end
  def handle_call({:update_user_profile, user_profile_changeset}, _from, state) do
    response = case Repo.update(user_profile_changeset) do
      {:error, changeset} -> {:error, changeset}
      {:ok, profile} ->
        p = Repo.preload(profile, :user_schema)
        Task.await(Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
        UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, :update, %{"user" => p.user_schema}, %UserManager.Struct.Notification{destination_pid: self()})
        receive do
          m -> m
        end
        end))
        {:ok, profile}
    end
    {:reply, response, state}
  end
  def handle_call({:insert_user, user}, _from, state) do
     response = case Repo.insert(user) do
        {:ok, user} ->
          Task.await(Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
          UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, :create, %{"user" => user}, %UserManager.Struct.Notification{destination_pid: self()})
          receive do
            m -> m
          end
         end))
        {:ok, user}
        {:error, changeset} -> {:error, changeset}
      end
      {:reply, response, state}
  end
end

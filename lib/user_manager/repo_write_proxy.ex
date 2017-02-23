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
            UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, :update, %{"user" => u})
            UserManager.Notifications.NotificationResponseProcessor.flush()
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
          UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, :update, %{"user" => p.user_schema})
          UserManager.Notifications.NotificationResponseProcessor.flush()
        {:ok, profile}
    end
    {:reply, response, state}
  end
  def handle_call({:insert_user, user}, _from, state) do
     response = case Repo.insert(user) do
        {:ok, user} ->
          UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, :create, %{"user" => user})
          UserManager.Notifications.NotificationResponseProcessor.flush()
        {:ok, user}
        {:error, changeset} -> {:error, changeset}
      end
      {:reply, response, state}
  end
end

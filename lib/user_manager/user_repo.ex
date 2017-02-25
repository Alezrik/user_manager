defmodule UserManager.UserRepo do
  @moduledoc false
  use GenServer
  require Logger
  alias UserManager.Schemas.UserSchema
  alias UserManager.Repo
  import Ecto.Query
  def start_link(state, opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, state, opts)
    {:ok, pid}
  end

  def init(_opts) do
    #Process.send_after(self(), :register, 1_000)
    users = UserSchema
    |> Repo.all
    |> Enum.map(fn r -> UserManager.Struct.User.load_user(r.id) end)
    {:ok, users}
  end
  def delete_user(user_id) do
    GenServer.call(UserManager.UserRepo, {:delete_user, user_id})
  end
  def update_user_password(user_id, update_password) do
    GenServer.call(UserManager.UserRepo, {:update_user_password, user_id, update_password})
  end
  def handle_call({:update_user_password, user_id, update_password}, _from, state) do
    case UserSchema
    |> where(id: ^user_id)
    |> Repo.one do
      nil -> {:reply, {:error, :user_not_found}, state}
      usr ->
        user = Repo.preload(usr, :user_profile)
        updated_credentials = user.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.put("password", update_password)
        updated_credentials = Map.put(updated_credentials, "secretkey", "")
        update = %{"authentication_metadata" => Map.merge(user.user_profile.authentication_metadata, %{"credentials" => updated_credentials})}
        changeset = UserManager.Schemas.UserProfile.changeset(user.user_profile, update)
        response = execute_profile_update(changeset, user_id)
        {:reply, response, state}
    end
  end
  def handle_call({:delete_user, user_id}, _from, state) do
      case UserSchema
      |> where(id: ^user_id)
      |> Repo.one do
        nil -> {:reply, {:error, :user_not_found}, state}
        usr ->
        case Repo.delete(usr) do
          {:error, changeset} -> {:reply, {:error, :delete_error, changeset}, state}
          {:ok, _} ->
            process_crud_notification(:delete, %{"id" => user_id})
            {:reply, :ok, state}
        end
      end
  end
  def handle_call({:get_profile_id_for_user_id, user_id}, _from, state) do
    response = state |> Enum.filter(fn u ->
      u.user_schema_id == user_id
     end)
     |> Enum.map(fn u -> u.user_profile_id end)
     case response do
       [] -> {:reply, {:user_not_found}, state}
       [id] -> {:reply, {id}, state}
     end
  end
  def handle_call({:get_user_id_for_authentication_name, authentication_name}, _from, state) do
    Logger.debug "getuser state: #{inspect state}"
    response = Enum.filter(state, fn u ->
      provider = Enum.filter(u.authenticate_providers, fn provider ->
        case provider do
          {:credential, name, _, _} -> name == authentication_name
          other -> false
        end
       end)
       Enum.count(provider) > 0
     end)
     case response do
       [] -> {:reply, {:user_not_found}, state}
       [u] ->
       {:reply, {u.user_schema_id}, state}
     end
  end
  def handle_call({:create_user_notify, user_id}, _from, state) when is_number(user_id) do
      {:noreply, [UserManager.Struct.User.load_user(user_id) | Enum.filter(state, fn s -> s.user_schema_id != user_id end)]}
    end
  def handle_call({:create_user_notify, user_id}, _from, state) do
    metadata = user_id.response_parameters
    user = Map.fetch!(metadata, "user")
    add_user = UserManager.Struct.User.load_user(user.id)
    {:reply, add_user, [add_user | Enum.filter(state, fn s -> s.user_schema_id != user.id end)]}
  end
  defp execute_profile_update(changeset, user_id) do
    case changeset.valid? do
      false -> {:error, :update_error, changeset}
      true -> case Repo.update(changeset) do
        {:error, _reason} -> {:error, :update_error, changeset}
        {:ok, _profile} ->
        user = UserSchema
        |> where(id: ^user_id)
        |> Repo.one!
        process_crud_notification(:update, %{"user" => user})
        {:ok, user}
      end
    end
  end
  defp process_crud_notification(command, metadata) do
   Logger.debug "user_repo sending: #{inspect command} with metadata: #{inspect metadata}"
   Task.await(Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
    UserManager.Notifications.NotificationResponseProcessor.process_notification(:user_crud, command, metadata, %UserManager.Struct.Notification{destination_pid: self()})
    receive do
      msg -> msg
    end
   end))
  end
  def handle_info({:notify, notification}, state) do
    case notification.notification_type do
      :update ->
       user = Map.fetch!(notification.response_parameters, "user")
       update_state =  [UserManager.Struct.User.load_user(user.id) | Enum.filter(state, fn s -> s.user_schema_id != user.id end)]
       {:noreply, update_state}
      :delete ->
        id = Map.fetch!(notification.response_parameters, "id")
        update_state = Enum.filter(state, fn  s ->  s.user_schema_id != id end)
       {:noreply, update_state}
      :create -> {:reply, _, update_state} = handle_call({:create_user_notify, notification}, nil, state)
                  {:noreply, update_state}
    end
  end
end

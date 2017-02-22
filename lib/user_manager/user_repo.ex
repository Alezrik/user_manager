defmodule UserManager.UserRepo do
  @moduledoc false
  use GenServer
  require Logger
  alias UserManager.Schemas.UserSchema
  alias UserManager.Repo
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
  def handle_info({:notify, notification}, state) do
     {:reply, event, update_state} = handle_call({:create_user_notify, notification}, nil, state)
    {:noreply, update_state}
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
    response = Enum.filter(state, fn u ->
      provider = Enum.filter(u.authenticate_providers, fn provider ->
        {_, name, _, _} = provider
        name == authentication_name
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
    user = Map.fetch!(metadata, "created_object")
    add_user = UserManager.Struct.User.load_user(user.id)
    {:reply, add_user, [add_user | Enum.filter(state, fn s -> s.user_schema_id != user.id end)]}
  end
  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end

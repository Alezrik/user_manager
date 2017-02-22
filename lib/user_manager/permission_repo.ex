defmodule UserManager.PermissionRepo do
  @moduledoc false
  use GenServer
  alias UserManager.Schemas.Permission
  alias UserManager.Repo
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    reload_state()
    {:ok, []}
  end
  def reload_state() do
    Permission
    |> Repo.all
    |> Repo.preload(:permission_group)
    |> Enum.map(fn per ->
    {:permission, per.id, per.name, per.permission_group.id, per.permission_group.name}
    end)
  end
  def handle_call({:get_permission_id_by_group_name_permission_name, group_name, permission_name}, _from, state) do

    state = case state do
      [] -> reload_state()
      other -> other
    end
    result = state
    |> Enum.filter(fn {:permission, permission_id, permission, group_id, group} ->
      (permission == Atom.to_string(permission_name)) && (group == Atom.to_string(group_name))
    end)
    |> Enum.map(fn {:permission, permission_id, permission, group_id, group} -> permission_id end)
    {:reply, result, state}
  end
  def handle_call({:get_default_user_create_permission_ids}, _from, state) do
    state = case state do
      [] -> reload_state()
      other -> other
    end
    default_permissions = Map.to_list(Application.get_env(:user_manager, :new_user_default_permissions))
    |> Enum.flat_map(fn {tag, tag_list} ->
      Enum.map(tag_list, fn t ->
      {tag, t} end)
     end)
    |> Enum.flat_map(fn {tag, per} ->
         state
         |> Enum.filter(fn s ->
          {:permission, _, p, _, t} = s
          (t == Atom.to_string(tag)) && (p == Atom.to_string(per))
          end)
         |> Enum.map(fn  {:permission, id, _, _, _} ->
          id end)
      end)
    {:reply, default_permissions, state}
  end
  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end

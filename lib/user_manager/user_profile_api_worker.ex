defmodule UserManager.UserProfileApiWorker do
  @moduledoc """
  api pooled worker
"""
  
  use GenServer
  alias UserManager.Repo
  alias UserManager.User
  alias UserManager.Permission
  import Ecto.Changeset
  import Ecto.Query
  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def create_user(pid, name, password) do
    GenServer.call(pid, {:create_user, name, password})
  end
  def handle_call({:create_user, name, password}, _from, state) do
    alias Permission
    user_changeset = User.changeset(%User{}, %{"name" => name, "password" => password})
    case create_user_from_changeset(user_changeset, user_changeset.valid?) do
      {:error, errors} ->{:reply, {:error, errors}, state}
      {:ok, insert} ->
        default_permissions = get_default_permissions()
        Enum.each(default_permissions, fn p ->
          u_list = [insert | p.users]
          changeset = Permission.changeset(p, %{}) |> put_assoc(:users, u_list)
          Repo.update(changeset)
         end)
        {:reply, {:ok, insert}, state}
    end
  end
  defp get_default_permissions() do
    alias UserManager.PermissionGroup
    group = PermissionGroup
    |> where(name: "default")
    |> Repo.one!
    |> Repo.preload(:permissions)
    permissions = Enum.filter(group.permissions, fn x ->  x.name == "read" end)
    Enum.map(permissions, fn x -> x |> Repo.preload(:users) end)

  end
  defp create_user_from_changeset(user_changeset, true) do
    Repo.insert(user_changeset)
  end
  defp create_user_from_changeset(user_changeset, false) do
    {:error, user_changeset.errors}
  end
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
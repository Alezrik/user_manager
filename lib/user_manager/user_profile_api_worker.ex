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
  @spec create_user(Pid.t, String.t, String.t) :: {atom, UserManager.User}
  def create_user(pid, name, password) do
    GenServer.call(pid, {:create_user, name, password}, Application.get_env(:user_manager, :user_profile_request_timeout))
  end
  def handle_call({:create_user, name, password}, _from, state) do
    alias Permission
    user_changeset = User.changeset(%User{}, %{"name" => name, "password" => password})
    case create_user_from_changeset(user_changeset, user_changeset.valid?) do
      {:error, errors}  -> {:reply, {:error, errors}, state}
      {:ok, insert} ->
        get_default_permissions() |> Stream.each(fn p ->
          changeset = p |> Permission.changeset(%{})
          |> put_assoc(:users, [insert | p.users])
          |> Repo.update
         end) |> Enum.to_list
        {:reply, {:ok, insert}, state}
    end
  end
  @spec get_default_permissions() :: Enum.t
  defp get_default_permissions() do
    alias UserManager.PermissionGroup
    group = PermissionGroup
    |> where(name: "default")
    |> Repo.one!
    |> Repo.preload(:permissions)
    permissions = Enum.filter(group.permissions, fn x ->  x.name == "read" end)
    Enum.map(permissions, fn x -> x |> Repo.preload(:users) end)

  end
  @spec create_user_from_changeset(Map.t, true) :: {atom, UserManager.User}
  defp create_user_from_changeset(user_changeset, true) do
    Repo.insert(user_changeset)
  end
  @spec create_user_from_changeset(Map.t, false) :: {atom, Enum.t}
  defp create_user_from_changeset(user_changeset, false) do
    {:error, user_changeset.errors}
  end
end
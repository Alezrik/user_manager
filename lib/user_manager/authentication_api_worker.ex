defmodule UserManager.AuthenticationApiWorker do
  @moduledoc """
  pooled worker for Authentication related tasks
"""
  
  use GenServer
  alias UserManager.User
  alias UserManager.Repo
  import Ecto.Query
  require Logger
  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  def init(_opts) do
    {:ok, %{}}
  end
  @spec authenticate_user(Pid.t, String.t, binary, atom) :: {atom} | {atom, UserManager.User | String.t}
  def authenticate_user(pid, name, password, authenticate_source) do
    GenServer.call(pid, {:authenticate_user, name, password, authenticate_source}, Application.get_env(:user_manager, :authenticate_request_timeout))
  end
  @spec identify_user(Pid.t, String.t, atom) :: {atom, UserManager.User | String.t}
  def identify_user(pid, token, authenticate_source) do
    GenServer.call(pid, {:identify_user, token, authenticate_source}, Application.get_env(:user_manager, :authenticate_request_timeout))
  end
  def handle_call({:identify_user, token, authenticate_source}, _from, state) do
    response = case Guardian.decode_and_verify(token) do
      {:error, reason} -> {:error}
        {:ok, data} -> case UserManager.GuardianSerializer.from_token(Map.fetch!(data, "sub")) do
              {:ok, user} -> {:ok, user}
              other -> {:error}
        end
    end
    {:reply, response, state}
  end
  def handle_call({:authenticate_user, name, password, authenticate_source}, _from, state) do
    authenticate_response = case User
    |> where(name: ^name)
    |> Repo.one do
      nil -> {:error}
      user ->
         handle_authenticate(user.password == password, user, authenticate_source)
    end
    {:reply, authenticate_response, state}
  end
  @spec handle_authenticate(true, UserManager.User, atom) :: {:ok, String.t} | {:error}
  def handle_authenticate(true, user, authenticate_source \\ :browser) when user != nil and is_atom(authenticate_source) do
      user = user |> Repo.preload(:permissions)
      permissions = group_permissions(user.permissions)
      case Guardian.encode_and_sign(user, authenticate_source, %{"perms" => permissions}) do
        {:ok, jtw, data} -> {:ok, jtw}
        other -> {:error}
      end
  end
  @spec handle_authenticate(false, UserManager.User, atom) :: {atom}
  def handle_authenticate(false, user, authenticate_source) do
    {:error}
  end
  @spec group_permissions(List.t) :: Map.t
  defp group_permissions(user_permission_list) do
    Enum.group_by(user_permission_list, fn x ->
      permission = x |> Repo.preload(:permission_group)
      String.to_atom(permission.permission_group.name)
      end, fn x -> String.to_atom(x.name) end)
  end
end
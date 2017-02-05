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
  def authenticate_user(pid, name, password, authenticate_source) do
    GenServer.call(pid, {:authenticate_user, name, password, authenticate_source})
  end
  def identify_user(pid, token, authenticate_source) do
    GenServer.call(pid, {:identify_user, token, authenticate_source})
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
        case user.password == password do
          false -> {:error}
          true ->
              user = user |> Repo.preload(:permissions)
              permissions = Enum.group_by(user.permissions, fn x ->
               x = x |> Repo.preload(:permission_group)
               String.to_atom(x.permission_group.name)
               end, fn x ->
                  String.to_atom(x.name)
                end)
              {:ok, jtw, _} = Guardian.encode_and_sign(user, authenticate_source, perms: permissions)
              {:ok, jtw}
        end

    end
    {:reply, authenticate_response, state}
  end
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
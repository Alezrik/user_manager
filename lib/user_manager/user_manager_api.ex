defmodule UserManager.UserManagerApi do
  @moduledoc """
  External API for UserManager Workflows
"""
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  @spec create_user(String.t, String.t) :: {atom, UserManager.User.t} | {atom, atom, String.t}
  def create_user(name, password) do
      Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
      GenServer.cast(UserManager.CreateUser.CreateUserWorkflowProducer, {:create_user, name, password, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(60_000)
  end
  @spec authenticate_user(String.t, String.t, atom) :: {atom, String.t} | {atom, atom, String.t} | {atom, atom}
  def authenticate_user(name, password, authentication_source \\ :browser) do
    Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
      GenServer.cast(UserManager.Authenticate.AuthenticateUserWorkflowProducer, {:authenticate_user, name, password, authentication_source, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(1000)
  end
  @spec identify_user(String.t) :: {atom, UserManager.User.t} | {atom, atom} | {atom, atom, String.t}
  def identify_user(token) do
    Logger.warn "state: #{inspect token}"
    Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
      GenServer.cast(UserManager.Identify.IdentifyUserProducer, {:identify_user, token, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(1000)
  end
  @spec authorize_claims(String.t, Enum.t, bool) :: {atom} | {atom, atom} | {atom, atom, String.t}
  def authorize_claims(token, permission_list, require_all \\ true) do
    Task.Supervisor.async(UserManager.Task.Supervisor, fn ->
      GenServer.cast(UserManager.Authorize.AuthorizeUserWorkflowProducer, {:authorize_token, token, permission_list, require_all, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(1000)
  end
end
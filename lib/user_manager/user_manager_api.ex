defmodule UserManager.UserManagerApi do
  @moduledoc """
  External API for UserManager Workflows.

  Functionality will be exposed here as workflows are added
"""
  require Logger
  @doc"""
  Creates a User a UserProfile and Permissions

  Default Create Permissions List is configurable in config:
  config :user_manager,
    new_user_default_permissions: ###SomeGuardianPermissionListHere###

"""
  @spec create_user(String.t, String.t, String.t) :: {atom, UserManager.User.t} | {atom, atom, String.t}
  def create_user(name, password, email) do
      UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      GenServer.cast(UserManager.CreateUser.CreateUserWorkflowProducer, {:create_user, name, password, email, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end

  @doc"""
  Validates a name and password against a UserProfile, if successful returns a token based upon the
  Guardian token_type 'authentication_source'
"""
  @spec authenticate_user(String.t, String.t, atom) :: {atom, String.t} | {atom, atom, String.t} | {atom, atom}
  def authenticate_user(name, password, authentication_source \\ :browser) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      GenServer.cast(UserManager.Authenticate.AuthenticateUserWorkflowProducer, {:authenticate_user, name, password, authentication_source, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end
  @spec identify_user(String.t) :: {atom, UserManager.User.t} | {atom, atom} | {atom, atom, String.t}

  @doc"""
  Looks up a user from a token
"""
  def identify_user(token) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      GenServer.cast(UserManager.Identify.IdentifyUserProducer, {:identify_user, token, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end
  @doc """
  authenticates a user from a list of permissions.
  require_all is used to specify if all permissions are required or only a single_permission would be required
  to meet the requirement.
  """
  @spec authorize_claims(String.t, Enum.t, bool) :: {atom} | {atom, atom} | {atom, atom, String.t}
  def authorize_claims(token, permission_list, require_all \\ true) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      GenServer.cast(UserManager.Authorize.AuthorizeUserWorkflowProducer, {:authorize_token, token, permission_list, require_all, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end
end

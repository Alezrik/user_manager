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
  def create_user(name, password, email) do
      UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      notify = %UserManager.Struct.Notification{destination_pid: self()}
      GenServer.cast(UserManager.CreateUser.CreateUserWorkflowProducer, {:create_user, name, password, email, notify})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end

  @doc"""
  Validates a name and password against a UserProfile, if successful returns a token based upon the
  Guardian token_type 'authentication_source'
"""
  def authenticate_user(name, password, authentication_source \\ :browser) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      notify = %UserManager.Struct.Notification{destination_pid: self()}
      GenServer.cast(UserManager.Authenticate.AuthenticateUserWorkflowProducer, {:authenticate_user, name, password, authentication_source, notify})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end
  @doc"""
  Looks up a user from a token
"""
  def identify_user(token) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      notify = %UserManager.Struct.Notification{destination_pid: self()}
      GenServer.cast(UserManager.Identify.IdentifyUserProducer, {:identify_user, token, notify})
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
  def authorize_claims(token, permission_list, require_all \\ true) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      notify = %UserManager.Struct.Notification{destination_pid: self()}
      GenServer.cast(UserManager.Authorize.AuthorizeUserWorkflowProducer, {:authorize_token, token, permission_list, require_all, notify})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(Application.get_env(:user_manager, :syncronous_api_timeout))
  end
  def create_facebook_profile(user_id, facebook_code_token) do
    UserManager.Task.Supervisor |> Task.Supervisor.async(fn ->
      notify = %UserManager.Struct.Notification{destination_pid: self()}
      GenServer.cast(UserManager.CreateFacebookProfile.CreateFacebookProfileProducer, {:create_facebook_profile, facebook_code_token, user_id, notify})
      receive do
        some_msg -> some_msg
      end
     end) |> Task.await(Application.get_env(:user_manager, :facebook_profile_timeout))
  end
end

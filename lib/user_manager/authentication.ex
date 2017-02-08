defmodule UserManager.Authentication.Supervisor do
  @moduledoc """
  supervises Authentication GenServers & AuthenticationApiPool
"""
  
  use Supervisor
  @spec api_pool_name() :: atom
  def api_pool_name() do
    :authentication_api_pool
  end
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, Authentication.Supervisor)
    {:ok, pid}
  end


  def init(arg) do

    children = [
      worker(UserManager.Authenticate.AuthenticateUserWorkflowProducer, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserUserLookup, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserValidation, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserTokenGenerate, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserNotificationFormatter, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserNotification, [:ok]),
      worker(UserManager.AuthenticationApi, [:ok, [name: UserManager.AuthenticationApi]]),

      worker(UserManager.Identify.IdentifyUserProducer, [:ok]),
      worker(UserManager.Identify.IdentifyUserValidateToken, [:ok]),
      worker(UserManager.Identify.IdentifyUserDeserializer, [:ok]),
      worker(UserManager.Identify.IdentifyUserNotificationFormatter, [:ok]),
      worker(UserManager.Identify.IdentifyUserNotification, [:ok])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
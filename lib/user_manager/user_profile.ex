defmodule UserManager.UserProfile.Supervisor do
  @moduledoc """
  supervisor for UserProfile related GenServers and UserProfile api pool
"""
  
  use Supervisor
  @max_data_validators  10
  @max_repo_inserts 10
  @max_user_permissions 10
  @max_user_notification 10
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.UserProfile.Supervisor)
    {:ok, pid}
  end
  @spec api_pool_name() :: atom
  def api_pool_name() do
    :user_profile_api_pool
  end
  def init(arg) do


    children = [
      supervisor(Task.Supervisor, [[name: UserManager.UserProfile.Task.Supervisor]]),
      worker(UserManager.UserProfileApi, [:ok, [name: UserManager.UserProfileApi]]),
      #CreateUserWorkflow
      worker(UserManager.CreateUser.CreateUserWorkflowProducer, [:ok]),
      worker(UserManager.CreateUser.CreateUserDataValidator, [:ok]),
      worker(UserManager.CreateUser.CreateUserRepoInsert, [:ok]),
      worker(UserManager.CreateUser.CreateUserPermissions, [:ok]),
      worker(UserManager.CreateUser.CreateUserNotificationFormatter, [:ok]),
      worker(UserManager.CreateUser.CreateUserNotification, [:ok])
    ]

    supervise(children,
           strategy: :one_for_one)
  end
end
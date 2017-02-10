defmodule UserManager.CreateUser.CreateUserWorkflowSupervisor.Supervisor do
  @moduledoc false
  
  use Supervisor

  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.CreateUser.CreateUserWorkflowSupervisor.Supervisor)
    {:ok, pid}
  end

  def init(arg) do
    children = [
      worker(UserManager.CreateUser.CreateUserWorkflowProducer, [:ok]),
      worker(UserManager.CreateUser.CreateUserDataValidator, [:ok]),
      worker(UserManager.CreateUser.CreateUserRepoInsert, [:ok]),
      worker(UserManager.CreateUser.CreateUserPermissions, [:ok]),
      worker(UserManager.CreateUser.CreateUserNotificationFormatter, [:ok]),
      worker(UserManager.CreateUser.CreateUserNotification, [:ok])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
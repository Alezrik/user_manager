defmodule UserManager.Authorize.AuthorizeWorkflowSupervisor.Supervisor do
  @moduledoc false
  use Supervisor
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.Authorize.AuthorizeWorkflowSupervisor.Supervisor)
    {:ok, pid}
  end
  def init(arg) do
    children = [
      worker(UserManager.Authorize.AuthorizeUserWorkflowProducer, [:ok]),
      worker(UserManager.Authorize.AuthorizeUserValidateToken, [:ok]),
      worker(UserManager.Authorize.AuthorizeUserValidatePermissions, [:ok])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

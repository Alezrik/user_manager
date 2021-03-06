defmodule UserManager.Authenticate.AuthenticateWorkflowSupervisor.Supervisor do
  @moduledoc false
  use Supervisor
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.Authenticate.AuthenticateWorkflowSupervisor.Supervisor)
    {:ok, pid}
  end
  def init(arg) do
    children = [
      worker(UserManager.Authenticate.AuthenticateUserWorkflowProducer, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserUserLookup, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserValidation, [:ok]),
      worker(UserManager.Authenticate.AuthenticateUserTokenGenerate, [:ok])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

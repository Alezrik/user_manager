defmodule UserManager.Extern.ExternalProxySupervisor.Supervisor do
  @moduledoc false
  use Supervisor
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.Extern.ExternalProxySupervisor.Supervisor)
    {:ok, pid}
  end

  def init(arg) do
    children = [
      worker(UserManager.Extern.FacebookProxy, [:ok, [name: UserManager.Extern.FacebookProxy]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

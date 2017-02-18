defmodule UserManager.Extern.ExternalProxySupervisor.Supervisor do
  @moduledoc false
  use Supervisor
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(arg) do
    children = [
      worker(UserManager.Extern.FacebookProxy, [:ok, [name: UserManager.Extern.FacebookProxy]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

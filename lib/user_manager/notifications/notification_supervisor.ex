defmodule UserManager.Notifications.NotificationSupervisor.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.Notifications.NotificationSupervisor.Supervisor)
    {:ok, pid}
  end

  def init(arg) do
    children = [
      worker(UserManager.Notifications.NotificationResponseProcessor, [:ok, [name: UserManager.Notifications.NotificationResponseProcessor]]),
      worker(UserManager.Notifications.NotificationRequestInitiator, [:ok, [name: UserManager.Notifications.NotificationRequestInitiator]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

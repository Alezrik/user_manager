defmodule UserManager.Identify.IdentifyUserWorkflowSupervisor.Supervisor do
  @moduledoc """
  Supervisor for Identify User Workflow
"""
  
  use Supervisor

  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.Identify.IdentifyUserWorkflowSupervisor.Supervisor)
    {:ok, pid}
  end

  def init(arg) do
    children = [
      worker(UserManager.Identify.IdentifyUserProducer, [:ok]),
      worker(UserManager.Identify.IdentifyUserValidateToken, [:ok]),
      worker(UserManager.Identify.IdentifyUserDeserializer, [:ok]),
      worker(UserManager.Identify.IdentifyUserNotificationFormatter, [:ok]),
      worker(UserManager.Identify.IdentifyUserNotification, [:ok])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
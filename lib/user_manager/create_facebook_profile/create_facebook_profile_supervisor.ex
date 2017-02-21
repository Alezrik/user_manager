defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileSupervisor.Supervisor do
  @moduledoc false
  use Supervisor
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.CreateFacebookProfile.CreateFacebookProfileSupervisor.Supervisor)
    {:ok, pid}
  end

  def init(arg) do
    children = [
      worker(UserManager.CreateFacebookProfile.CreateFacebookProfileProducer, [:ok]),
      worker(UserManager.CreateFacebookProfile.CreateFacebookProfileValidateCodeToken, [:ok]),
      worker(UserManager.CreateFacebookProfile.CreateFacebookProfileGenerateServerToken, [:ok]),
      worker(UserManager.CreateFacebookProfile.CreateFacebookProfileRepoUpdate, [:ok])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

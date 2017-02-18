defmodule UserManager.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: UserManager.Worker.start_link(arg1, arg2, arg3)
      # worker(UserManager.Worker, [arg1, arg2, arg3]),
      worker(UserManager.Repo, []),
      worker(UserManager.UserRepo, [:ok, [name: UserManager.UserRepo]]),
      worker(UserManager.PermissionRepo, [:ok, [name: UserManager.PermissionRepo]]),
      supervisor(UserManager.Authenticate.AuthenticateWorkflowSupervisor.Supervisor, [:ok]),
      supervisor(UserManager.Authorize.AuthorizeWorkflowSupervisor.Supervisor, [:ok]),
      supervisor(UserManager.CreateUser.CreateUserWorkflowSupervisor.Supervisor, [:ok]),
      supervisor(UserManager.Identify.IdentifyUserWorkflowSupervisor.Supervisor, [:ok]),
      supervisor(UserManager.CreateFacebookProfile.CreateFacebookProfileSupervisor.Supervisor, [:ok]),
      supervisor(UserManager.Extern.ExternalProxySupervisor.Supervisor, [:ok]),
      supervisor(Task.Supervisor, [[name: UserManager.Task.Supervisor]])

    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UserManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule UserManager.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  main application & supervisor for user_manager
"""

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: UserManager.Worker.start_link(arg1, arg2, arg3)
      # worker(UserManager.Worker, [arg1, arg2, arg3]),
      supervisor(UserManager.Authentication.Supervisor, [:ok]),
      supervisor(UserManager.UserProfile.Supervisor , [:ok]),
      supervisor(UserManager.Authorization.Supervisor, [:ok]),
      worker(UserManager.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UserManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

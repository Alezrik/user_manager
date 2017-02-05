defmodule UserManager.Authentication.Supervisor do
  @moduledoc """
  supervises Authentication GenServers & AuthenticationApiPool
"""
  
  use Supervisor
  @spec api_pool_name() :: atom
  def api_pool_name() do
    :authentication_api_pool
  end
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, Authentication.Supervisor)
    {:ok, pid}
  end


  def init(arg) do
    poolboy_config = [
        {:name, {:local, api_pool_name()}},
        {:worker_module, UserManager.AuthenticationApiWorker},
        {:size, Application.get_env(:user_manager, :authenticate_workers)},
        {:max_overflow, Application.get_env(:user_manager, :authenticate_max_overflow)}
      ]
    children = [
      #worker(poolboy_config, []),
      :poolboy.child_spec(api_pool_name(), poolboy_config, []),
      worker(UserManager.AuthenticationApi, [:ok, [name: UserManager.AuthenticationApi]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
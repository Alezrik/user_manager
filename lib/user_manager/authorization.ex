defmodule UserManager.Authorization.Supervisor do
  @moduledoc """
  Supervises Authorization related GenServers + Authorization Api Pool
"""
  
  use Supervisor
  @spec api_pool_name() :: atom
  def api_pool_name() do
      :authorization_api_pool
  end
  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.Authorization.Supervisor)
    {:ok, pid}
  end
  def init(arg) do
    poolboy_config = [
      {:name, {:local, api_pool_name()}},
      {:worker_module, UserManager.AuthorizationApiWorker},
      {:size, Application.get_env(:user_manager, :authorization_workers)},
      {:max_overflow, Application.get_env(:user_manager, :authorization_max_overflow)}
    ]
    children = [
      :poolboy.child_spec(api_pool_name(), poolboy_config),
      worker(UserManager.AuthorizationApi, [:ok, [name: UserManager.AuthorizationApi]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
defmodule UserManager.UserProfile.Supervisor do
  @moduledoc """
  supervisor for UserProfile related GenServers and UserProfile api pool
"""
  
  use Supervisor

  def start_link(arg) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, arg)
    Process.register(pid, UserManager.UserProfile.Supervisor )
    {:ok, pid}
  end

  def api_pool_name() do
    :user_profile_api_pool
  end
  def init(arg) do

    poolboy_config = [
        {:name, {:local, api_pool_name()}},
        {:worker_module, UserManager.UserProfileApiWorker},
        {:size, 2},
        {:max_overflow, 1}
      ]
    children = [
      :poolboy.child_spec(api_pool_name(), poolboy_config, []),
      worker(UserManager.UserProfileApi, [:ok, [name: UserManager.UserProfileApi]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
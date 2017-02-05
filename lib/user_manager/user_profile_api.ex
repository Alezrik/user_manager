defmodule UserManager.UserProfileApi do
  @moduledoc """
  external api for UserProfile related tasks
"""
  
  use GenServer
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  def init(_opts) do
    {:ok, %{}}
  end
  @spec create_user(String.t, String.t) :: {atom, UserManager.User | Enum.t}
  def create_user(name, password) do
    :poolboy.transaction(
          UserManager.UserProfile.Supervisor.api_pool_name(),
          fn pid ->
            UserManager.UserProfileApiWorker.create_user(pid, name, password)
           end,
           :infinity
        )
  end
end
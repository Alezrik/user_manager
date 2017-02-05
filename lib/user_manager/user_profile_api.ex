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
  def create_user(name, password) do
    :poolboy.transaction(
          UserManager.UserProfile.Supervisor.api_pool_name(),
          fn pid ->
            UserManager.UserProfileApiWorker.create_user(pid, name, password)
           end
        )
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
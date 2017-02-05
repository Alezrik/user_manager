defmodule UserManager.AuthenticationApi do
  @moduledoc """
  external api for Authentication related tasks
"""
  
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def authenticate_user(name, password, authenticate_source \\ :browser) do
    :poolboy.transaction(
        UserManager.Authentication.Supervisor.api_pool_name(),
        fn pid ->
          UserManager.AuthenticationApiWorker.authenticate_user(pid, name, password, authenticate_source)
         end
      )
  end
  def identify_user(token, authenticate_source \\ :browser) do
     :poolboy.transaction(
            UserManager.Authentication.Supervisor.api_pool_name(),
            fn pid ->
              UserManager.AuthenticationApiWorker.identify_user(pid, token, authenticate_source)
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
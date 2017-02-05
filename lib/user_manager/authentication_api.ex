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
  @spec authenticate_user(String.t, String.t, atom) :: {atom, UserManager.User | String.t}
  def authenticate_user(name, password, authenticate_source \\ :browser) do
    :poolboy.transaction(
        UserManager.Authentication.Supervisor.api_pool_name(),
        fn pid ->
          UserManager.AuthenticationApiWorker.authenticate_user(pid, name, password, authenticate_source)
         end,
         :infinity
      )
  end
  @spec identify_user(String.t, atom) :: {atom}
  def identify_user(token, authenticate_source \\ :browser) do
     :poolboy.transaction(
            UserManager.Authentication.Supervisor.api_pool_name(),
            fn pid ->
              UserManager.AuthenticationApiWorker.identify_user(pid, token, authenticate_source)
             end,
             :infinity
          )
  end
end
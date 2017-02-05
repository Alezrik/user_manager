defmodule UserManager.AuthorizationApi do
  @moduledoc """
  external api for Authorization related tasks
"""
  
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def authorize_all_claims(token, claims_list, authentication_source \\ :browser) do
    :poolboy.transaction(
        UserManager.Authorization.Supervisor.api_pool_name(),
        fn pid ->
          UserManager.AuthorizationApiWorker.authorize_all_claims(pid, token, claims_list, authentication_source)
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
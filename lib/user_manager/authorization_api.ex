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
  @spec authorize_all_claims(String.t, Enum.t, atom) :: {atom}
  def authorize_all_claims(token, claims_list, authentication_source \\ :browser) do
    :poolboy.transaction(
        UserManager.Authorization.Supervisor.api_pool_name(),
        fn pid ->
          UserManager.AuthorizationApiWorker.authorize_all_claims(pid, token, claims_list, authentication_source)
         end,
         :infinity
      )
  end

end
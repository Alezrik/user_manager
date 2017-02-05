defmodule UserManager.AuthorizationApiWorker do
  @moduledoc """
  Authorization Api pooled worker
"""
  require Logger
  use GenServer

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  def init(_opts) do
    {:ok, %{}}
  end
  @spec authorize_all_claims(Pid.t, String.t, Enum.t, atom) :: {atom}
  def authorize_all_claims(pid, token, claims_list, authentication_source) do
    GenServer.call(pid, {:authorize_all, token, claims_list, authentication_source}, Application.get_env(:user_manager, :authorization_request_timeout))
  end
  #@spec authorize_any_claims(Pid.t, String.t, Enum.t, atom) :: {atom}
  #def authorize_any_claims(pid, token, claims_list, authentication_source)
  def handle_call({:authorize_all, token, claims_list, authentication_source}, _from, state) do
    response = case Guardian.decode_and_verify(token) do
          {:error, reason} -> {:error}
            {:ok, data} ->
                claims_result = Enum.map(claims_list, fn c ->
                   {group_name, permission} = c
                   p = data
                   |> Guardian.Permissions.from_claims(group_name)
                   |> Guardian.Permissions.all?([permission], group_name)
                 end)
                 case Enum.member?(claims_result, false) do
                   true -> {:error}
                   false -> {:ok}
                 end
    end
    {:reply, response, state}
  end

end
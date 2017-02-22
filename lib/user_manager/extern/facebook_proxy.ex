defmodule UserManager.Extern.FacebookProxy do
  @moduledoc false
  use GenServer
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  def init(_opts) do
    {:ok, %{}}
  end
  def get_me(field_names_string, access_key) do
    {:ok, res} = GenServer.call(UserManager.Extern.FacebookProxy, {:get_me, field_names_string, access_key})
    res
  end
  def get_access_key_from_code(code) do
    res = GenServer.call(UserManager.Extern.FacebookProxy, {:get_access_key_from_code, code})
    {res.body, res.status_code}
  end
  def get_server_token_from_access_key(access_token) do
    res = GenServer.call(UserManager.Extern.FacebookProxy, {:get_server_token_from_access_key, access_token})
    {res.body, res.status_code}
  end
  def handle_call({:get_me, field_names_string, access_key}, _from, _state) do
    {:json, res} = Facebook.me(field_names_string, access_key)
    {:reply, {:ok, res}, []}
  end
  def handle_call({:get_server_token_from_access_key, token}, _from, _state) do
    facebook_uri = Application.get_env(:facebook, :graph_url) <> "oauth/access_token?grant_type=fb_exchange_token&client_id=#{Application.get_env(:user_manager, :facebook_client_id)}&client_secret=#{Application.get_env(:facebook, :appsecret)}&fb_exchange_token=#{token}"
    response = HTTPoison.get! facebook_uri
    {:reply, response, []}
  end
  def handle_call({:get_access_key_from_code, code_token}, _from, _state) do
    facebook_uri = Application.get_env(:facebook, :graph_url) <> "oauth/access_token?client_id=#{Application.get_env(:user_manager, :facebook_client_id)}&redirect_uri=#{Application.get_env(:user_manager, :facebook_redirect_uri)}&client_secret=#{Application.get_env(:facebook, :appsecret)}&code=#{code_token}"
    response = HTTPoison.get! facebook_uri
    {:reply, response, []}
  end
end

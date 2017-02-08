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
  def authenticate_user_workflow(name, password, authentication_source \\ :browser) do
    raw_task_data = Task.Supervisor.async(UserManager.UserProfile.Task.Supervisor, fn ->
      UserManager.Authenticate.AuthenticateUserWorkflowProducer.authenticate_user(name, password, authentication_source, self())
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(60_000)
  end
  def identify_user_workflow(token) do
    raw_task_data = Task.Supervisor.async(UserManager.UserProfile.Task.Supervisor, fn ->
      UserManager.Identify.IdentifyUserProducer.identify_user(token, self())
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(60_000)
  end

end
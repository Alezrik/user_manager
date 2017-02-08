defmodule UserManager.UserProfileApi do
  @moduledoc """
  external api for UserProfile related tasks
"""
  require Logger
  use GenServer
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  def init(_opts) do
    {:ok, %{}}
  end
  @spec create_user(String.t, String.t) :: {atom, UserManager.User | Enum.t}
  def create_user(name, password) do
      raw_task_data = Task.Supervisor.async(UserManager.UserProfile.Task.Supervisor, fn ->
      GenServer.cast(UserManager.CreateUser.CreateUserWorkflowProducer, {:create_user, name, password, self()})
      receive do
        some_msg -> some_msg
      end
    end) |> Task.await(60_000)
    case raw_task_data do
      {:ok, task_data} -> {:ok, task_data}
      {:error, error_data} -> {:error, :task_error, error_data}
      {:error, error_tag, error_data} -> {:error, error_tag, error_data}
    end

  end
end
defmodule UserManager.CreateUser.CreateUserDataValidator do
  @moduledoc false
  use GenStage
  alias UserManager.User
  require Logger
   def start_link(setup) do
      name = "#{__MODULE__}#{setup}"
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:producer_consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserWorkflowProducer]}
  end
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.map(fn e ->
      {:create_user, name, password, notify} = e
     user_changeset = User.changeset(%User{}, %{"name" => name, "password" => password})
     case user_changeset.valid? do
        true -> {:insert_user, user_changeset, notify}
        false -> {:validation_error, user_changeset.errors, notify}
     end
     end)
     |> Enum.to_list
    {:noreply, process_events, state}
  end
end
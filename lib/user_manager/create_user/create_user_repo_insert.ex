defmodule UserManager.CreateUser.CreateUserRepoInsert do
  @moduledoc false
  use GenStage
  alias UserManager.Repo
  require Logger
   def start_link(setup) do
         name = "#{__MODULE__}#{setup}"
         GenStage.start_link(__MODULE__, [], name: __MODULE__)
     end
  def init(stat) do

    {:producer_consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserDataValidator]}
  end
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.map(fn e ->
      case e do
              {:insert_user, user_changeset, notify} ->
              case Repo.insert(user_changeset) do
                {:ok, user} -> {:insert_permissions, user, notify}
                {:error, changeset} -> {:insert_error, changeset.errors, notify}
              end
              {:validation_error, errors, notify} ->
               e
            end
     end)
    |> Enum.to_list
    {:noreply, process_events, state}
  end
end
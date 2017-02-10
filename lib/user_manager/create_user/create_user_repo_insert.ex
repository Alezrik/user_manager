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
    process_events =  events |> UserManager.WorkflowProcessing.get_process_events(:insert_user)
    |> Flow.from_enumerable
    |> Flow.map(fn {:insert_user, user_changeset, notify} ->
      case Repo.insert(user_changeset) do
        {:ok, user} -> {:insert_permissions, user, notify}
        {:error, changeset} -> {:insert_error, changeset.errors, notify}
      end
     end)
    |> Enum.to_list
    un_processed_events =  UserManager.WorkflowProcessing.get_unprocessed_events(events, :insert_user)
    {:noreply, process_events ++ un_processed_events, state}
  end
end
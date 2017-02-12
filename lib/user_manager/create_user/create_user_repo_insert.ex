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
  @doc"""
  responsible for saving changelist(s) for user data

  ## Examples

     iex>userchangeset =UserManager.Schemas.UserSchema.changeset( %UserManager.Schemas.UserSchema{}, %{})
     iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserRepoInsert.handle_events([{:insert_user, userchangeset, nil}], self(), [])
     iex>Enum.at(Tuple.to_list(Enum.at(response,0)),0)
     :insert_permissions
"""
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

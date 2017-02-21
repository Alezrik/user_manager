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
    process_events = events
    |> Flow.from_enumerable
    |> Flow.flat_map(fn e -> process_event(e) end)
    |> Enum.to_list
    {:noreply, process_events, state}
  end
  defp process_event({:insert_user, user_changeset, notify}) do
    case Repo.insert(user_changeset) do
      {:ok, user} -> [{:insert_permissions, user, notify}]
      {:error, changeset} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_user, :insert_error, UserManager.Notifications.NotificationMetadataHelper.build_changeset_validation_error(:user, changeset), notify)
                              []
    end
  end
end

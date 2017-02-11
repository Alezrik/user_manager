defmodule UserManager.CreateUser.CreateUserNotificationFormatter do
   @moduledoc false
    use GenStage
    alias UserManager.Repo
    require Logger
     def start_link(setup) do
           name = "#{__MODULE__}#{setup}"
           GenStage.start_link(__MODULE__, [], name: __MODULE__)
       end
    def init(stat) do

      {:producer_consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserPermissions]}
    end
    def handle_events(events, from, state) do
      format_events = events
      |> Flow.from_enumerable
      |> Flow.flat_map(fn e ->
          case e do
             {:ok, nil} -> []
             {:update_permission_error, nil, _} -> []
             {:validation_error, _, nil} -> []
             {:insert_error, _, nil} -> []
             {:ok, notify, user} -> [{:notify_success, :create_user, notify, user}]
             {:update_permission_error, notify, errors} -> [{:notify_error, :update_permission_error, notify, errors}]
             {:validation_error, errors, notify} -> [{:notify_error, :create_user_validation_error, notify, errors}]
             {:insert_error, errors, notify} -> [{:notify_error, :create_user_insert_error, notify, errors}]
          end
       end)
      |> Enum.to_list
      {:noreply, format_events, state}
    end
end

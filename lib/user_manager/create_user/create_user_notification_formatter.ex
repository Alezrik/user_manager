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
    @doc"""
    responsble for final preparation of the notification return

    ## Examples

    ### strip messages without notify endpoints

      iex>UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:ok, nil, %UserManager.Schemas.UserSchema{id: 2}}], nil, [])
      {:noreply, [{:create_user_notify, 2}], []}

      iex>UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:update_permission_error, nil, ""}], nil, [])
      {:noreply, [], []}

      iex>UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:insert_error, "", nil}], nil, [])
      {:noreply, [], []}

      iex>UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:validation_error, "", nil}], nil, [])
      {:noreply, [], []}

    ### generate notifications for items with notify

      iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:ok, self(), %UserManager.Schemas.UserSchema{id: 2}}], self(), [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
      :notify_success
      iex>Enum.count(response)
      2
      iex>Enum.at(Tuple.to_list(Enum.at(response, 1)), 0)
      :create_user_notify

      iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:validation_error, "", self()}], self(), [])
      iex>Enum.at(Tuple.to_list(Enum.at(response,0)) ,0)
      :notify_error
      iex>Enum.at(Tuple.to_list(Enum.at(response,0)) ,1)
      :create_user_validation_error

      iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:update_permission_error, self(), ["errors"]}], self(), [])
      iex>Enum.at(Tuple.to_list(Enum.at(response,0)) ,0)
      :notify_error
      iex>Enum.at(Tuple.to_list(Enum.at(response,0)) ,1)
      :update_permission_error

      iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserNotificationFormatter.handle_events([{:insert_error, ["errors"], self()}], self(), [])
      iex>Enum.at(Tuple.to_list(Enum.at(response,0)) ,0)
      :notify_error
      iex>Enum.at(Tuple.to_list(Enum.at(response,0)) ,1)
      :create_user_insert_error
"""
    def handle_events(events, from, state) do
      format_events = events
      |> Flow.from_enumerable
      |> Flow.flat_map(fn e ->
          case e do
             {:ok, nil, user} -> [{:create_user_notify, user.id}]
             {:update_permission_error, nil, _} -> []
             {:validation_error, _, nil} -> []
             {:insert_error, _, nil} -> []
             {:ok, notify, user} -> [{:notify_success, :create_user, notify, user}, {:create_user_notify, user.id}]
             {:update_permission_error, notify, errors} -> [{:notify_error, :update_permission_error, notify, errors}]
             {:validation_error, errors, notify} -> [{:notify_error, :create_user_validation_error, notify, errors}]
             {:insert_error, errors, notify} -> [{:notify_error, :create_user_insert_error, notify, errors}]
          end
       end)
      |> Enum.to_list
      {:noreply, format_events, state}
    end
end

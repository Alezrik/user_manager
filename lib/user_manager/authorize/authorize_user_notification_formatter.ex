defmodule UserManager.Authorize.AuthorizeUserNotificationFormatter do
  @moduledoc false
    use GenStage
    alias UserManager.Repo
    require Logger
     def start_link(setup) do
           name = "#{__MODULE__}#{setup}"
           GenStage.start_link(__MODULE__, [], name: __MODULE__)
       end
    def init(stat) do

      {:producer_consumer, [], subscribe_to: [UserManager.Authorize.AuthorizeUserValidatePermissions]}
    end
    @doc"""
    format notification messages

    ## Examples
      iex>UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:ok, nil}], nil, [])
      {:noreply, [], []}

      iex>UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:error, :token_decode_error, "", nil}], nil, [])
      {:noreply, [], []}

      iex>UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:error, :unauthorized, nil}], nil, [])
      {:noreply, [], []}

      iex>{:noreply, response, _} = UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:ok, self()}], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
      :notify_success
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
      :authorize_user

      iex>{:noreply, response, _} = UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:error, :token_decode_error, "", self()}], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
      :notify_error
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
      :token_decode_error

      iex>{:noreply, response, _} = UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:error, :token_not_found, self()}], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
      :notify_error
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
      :token_not_found

      iex>{:noreply, response, _} = UserManager.Authorize.AuthorizeUserNotificationFormatter.handle_events([{:error, :unauthorized, self()}], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
      :notify_error
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
      :unauthorized



"""
    def handle_events(events, from, state) do
      format_events = events
      |> Flow.from_enumerable
      |> Flow.flat_map(fn e ->
          case e do
            {:ok, nil} -> []
            {:error, :token_decode_error, _, nil} -> []
            {:error, :token_not_found, nil} -> []
            {:error, :unauthorized, nil} -> []
            {:ok, notify} -> [{:notify_success, :authorize_user, notify}]
            {:error, :token_decode_error, reason, notify} -> [{:notify_error, :token_decode_error, notify, reason}]
            {:error, :token_not_found, notify} -> [{:notify_error, :token_not_found, notify}]
            {:error, :unauthorized, notify} -> [{:notify_error, :unauthorized, notify}]
          end
      end)
      |> Enum.to_list
      {:noreply, format_events, state}
    end
end

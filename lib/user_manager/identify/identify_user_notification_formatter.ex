defmodule UserManager.Identify.IdentifyUserNotificationFormatter do
  @moduledoc false

      use GenStage
      alias UserManager.Repo
      require Logger
       def start_link(setup) do
             name = "#{__MODULE__}#{setup}"
             GenStage.start_link(__MODULE__, [], name: __MODULE__)
         end
      def init(stat) do

        {:producer_consumer, [], subscribe_to: [UserManager.Identify.IdentifyUserDeserializer]}
      end
      @doc"""
      format for notification

      ## Example
         iex>UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:ok, "", nil}], nil, [])
         {:noreply, [], []}

         iex>UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:error, :token_not_found, nil}], nil, [])
         {:noreply, [], []}

         iex>UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:error, :token_decode_error, "something", nil}], nil, [])
         {:noreply, [], []}

         iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:ok, "pretend_ima_user", self}], nil, [])
         iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
         :notify_success
         iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
         :identify_user

        iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:error, :token_not_found, self}], nil, [])
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
        :notify_error
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
        :token_not_found

        iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:error, :token_decode_error, "something", self}], nil, [])
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
        :notify_error
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
        :token_decode_error

        iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserNotificationFormatter.handle_events([{:error, :user_deserialize_error, self}], nil, [])
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
        :notify_error
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
        :user_deserialize_error
"""
      def handle_events(events, from, state) do
        format_events = events
        |> Flow.from_enumerable
        |> Flow.flat_map(fn e -> get_notifications(e) end)
        |> Enum.to_list
        {:noreply, format_events, state}
      end
      defp get_notifications({:ok, _, nil}) do
        []
      end
      defp get_notifications({:error, :user_deserialize_error, nil}) do
        []
      end
      defp get_notifications({:error, :token_not_found, nil}) do
        []
      end
      defp get_notifications({:error, :token_decode_error, _, nil}) do
        []
      end
      defp get_notifications({:ok, user, notify}) do
        [{:notify_success, :identify_user, notify, user}]
      end
      defp get_notifications({:error, :user_deserialize_error, notify}) do
        [{:notify_error, :user_deserialize_error, notify}]
      end
      defp get_notifications({:error, :token_not_found, notify}) do
        [{:notify_error, :token_not_found, notify}]
      end
      defp get_notifications({:error, :token_decode_error, reason, notify}) do
        [{:notify_error, :token_decode_error, notify, reason}]
      end
end

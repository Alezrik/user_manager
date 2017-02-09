defmodule UserManager.Authorize.AuthorizeUserNotification do
  @moduledoc false
    use GenStage
      require Logger
       def start_link(setup) do

          GenStage.start_link(__MODULE__, [], name: __MODULE__)
      end
      def init(stat) do

        {:consumer, [], subscribe_to: [UserManager.Authorize.AuthorizeUserNotificationFormatter]}
      end
      def handle_events(events, from, state) do
        Flow.from_enumerable(events)
        |> Flow.each(fn e ->
            case e do
              {:notify_success, :authorize_user, notify} -> :ok = Process.send(notify, {:ok}, [])
             {:notify_error, :token_decode_error, notify, reason} -> :ok = Process.send(notify, {:error, :token_decode_error}, [])
              {:notify_error, :token_not_found, notify} -> :ok = Process.send(notify, {:error, :token_not_found}, [])
              {:notify_error, :unauthorized, notify} -> :ok = Process.send(notify, {:error, :unauthorized}, [])
            end
         end)
         |> Enum.to_list

        {:noreply, [], state}
      end
end
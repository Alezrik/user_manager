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
        processed_events = events
        |> Flow.from_enumerable()
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

      defp process_notification({:notify_success, :authorize_user, notify}) do
        :ok = Process.send(notify, {:ok}, [])
      end
      defp process_notification({:notify_error, :token_decode_error, notify, reason}) do
        :ok = Process.send(notify, {:error, :token_decode_error}, [])
      end
      defp process_notification({:notify_error, :token_not_found, notify}) do
        :ok = Process.send(notify, {:error, :token_not_found}, [])
      end
      defp process_notification({:notify_error, :unauthorized, notify}) do
        :ok = Process.send(notify, {:error, :unauthorized}, [])
      end
end

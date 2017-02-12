defmodule UserManager.Identify.IdentifyUserNotification do
  @moduledoc false
  use GenStage
    require Logger
     def start_link(setup) do
        GenStage.start_link(__MODULE__, [], name: __MODULE__)
    end
    def init(stat) do
      {:consumer, [], subscribe_to: [UserManager.Identify.IdentifyUserNotificationFormatter]}
    end
    def handle_events(events, from, state) do
      processed_events = events
      |> Flow.from_enumerable()
      |> Flow.each(fn e -> process_notification(e) end)
       |> Enum.to_list
       {:noreply, [], state}
    end
    defp process_notification({:notify_success, :identify_user, notify, user}) do
      :ok = Process.send(notify, {:ok, user}, [])
    end
    defp process_notification({:notify_error, :user_deserialize_error, notify}) do
      :ok = Process.send(notify, {:error, :user_deserialize_error}, [])
    end
    defp process_notification({:notify_error, :token_not_found, notify}) do
      :ok = Process.send(notify, {:error, :token_not_found}, [])
    end
    defp process_notification({:notify_error, :token_decode_error, notify, reason}) do
      :ok = Process.send(notify, {:error, :token_decode_error, reason}, [])
    end
end

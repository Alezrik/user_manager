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
      events
      |> Flow.from_enumerable()
      |> Flow.each(fn e ->
          case e do
            {:notify_success, :identify_user, notify, user} -> :ok = Process.send(notify, {:ok, user}, [])
            {:notify_error, :user_deserialize_error, notify} -> :ok = Process.send(notify, {:error, :user_deserialize_error}, [])
            {:notify_error, :token_not_found, notify} -> :ok = Process.send(notify, {:error, :token_not_found}, [])
            {:notify_error, :token_decode_error, notify, reason} -> :ok = Process.send(notify, {:error, :token_decode_error, reason}, [])
          end

       end)
       |> Enum.to_list
       {:noreply, [], state}
    end
end
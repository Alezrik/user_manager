defmodule UserManager.Authenticate.AuthenticateUserNotification do
  @moduledoc false
  use GenStage
    require Logger
     def start_link(setup) do
        name = "#{__MODULE__}#{setup}"
        GenStage.start_link(__MODULE__, [], name: __MODULE__)
    end
    def init(stat) do

      {:consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserNotificationFormatter]}
    end
    def handle_events(events, from, state) do
      Flow.from_enumerable(events)
      |> Flow.each(fn e ->
          case e do
            {:notify_success, :authentication, notify, token}  -> :ok = Process.send(notify, {:ok, token}, [])
            {:notify_error, :user_not_found, notify} -> :ok = Process.send(notify, {:error, :user_not_found}, [])
            {:notify_error, :authenticate_failure, notify} -> :ok = Process.send(notify, {:error, :authenticate_failure}, [])
            other -> Logger.warn"not notifying: #{inspect other}"
          end
       end) |> Enum.to_list

      {:noreply, [], state}
    end
end
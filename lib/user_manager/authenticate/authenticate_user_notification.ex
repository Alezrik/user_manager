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
      processed_events = events
      |> Flow.from_enumerable()
      |> Flow.each(fn e -> process_notification(e) end) |> Enum.to_list

      {:noreply, [], state}
    end

    def process_notification({:notify_success, :authentication, notify, token}) do
      :ok = Process.send(notify, {:ok, token}, [])
    end
    def process_notification({:notify_error, :user_not_found, notify}) do
      :ok = Process.send(notify, {:error, :user_not_found}, [])
    end
    def process_notification({:notify_error, :authenticate_failure, notify}) do
      :ok = Process.send(notify, {:error, :authenticate_failure}, [])
    end
end

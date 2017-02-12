defmodule UserManager.CreateUser.CreateUserNotification do
  @moduledoc false
  use GenStage
  require Logger
   def start_link(setup) do
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserNotificationFormatter]}
  end
  def handle_events(events, from, state) do
    processed_events = events
    |> Flow.from_enumerable()
    |> Flow.each(fn e -> process_notification(e) end) |> Enum.to_list
    {:noreply, [], state}
  end
  defp process_notification({:notify_success, :create_user, notify, user}) do
    :ok = Process.send(notify, {:ok, user}, [])
  end
  defp process_notification({:notify_error, :create_user_validation_error, notify, errors}) do
    :ok = Process.send(notify, {:error, :create_user_validation_error, errors}, [])
  end
  defp process_notification({:notify_error, :update_permission_error, notify, errors}) do
    :ok = Process.send(notify, {:error, :update_permission_error, errors}, [])
  end
  defp process_notification({:notify_error, :create_user_insert_error, notify, errors}) do
    :ok = Process.send(notify, {:error, :create_user_insert_error, errors}, [])
  end
  defp process_notification({:create_user_notify, user_id}) do
    GenServer.cast(UserManager.UserRepo, {:create_user_notify, user_id})
  end
end

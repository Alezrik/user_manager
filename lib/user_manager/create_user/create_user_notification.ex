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
    Flow.from_enumerable(events)
    |> Flow.each(fn e ->
        case e do
          {:notify_success, :create_user, notify, user}  -> :ok = Process.send(notify, {:ok, user}, [])
          {:notify_error, :create_user_validation_error, notify, errors} -> :ok = Process.send(notify, {:error, :create_user_validation_error, errors}, [])
          {:notify_error, :update_permission_error, notify, errors} -> :ok = Process.send(notify, {:error, :update_permission_error, errors}, [])
          {:notify_error, :create_user_insert_error, notify, errors} -> :ok = Process.send(notify, {:error, :create_user_insert_error, errors}, [])
        end
     end) |> Enum.to_list

    {:noreply, [], state}
  end
end
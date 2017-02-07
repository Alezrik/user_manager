defmodule UserManager.UserProfile.CreateUserNotification do
  @moduledoc false
  use GenStage
  require Logger
   def start_link(setup) do
      name = "#{__MODULE__}#{setup}"
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do

    {:consumer, [], subscribe_to: [UserManager.UserProfile.CreateUserPermissions]}
  end
  def handle_events(events, from, state) do
    Flow.from_enumerable(events)
    |> Flow.each(fn e ->
        case e do
          {:notify_success, notify, user} when notify != nil -> :ok = Process.send(notify, {:ok, user}, [])
          {some_error, notify, error_tag, error_list} when notify != nil -> :ok = Process.send(notify, {:error, error_tag, error_list}, [])
          {:notify_error, _, :insert_error, error_list} -> Logger.debug "insert_error nil notify: #{inspect error_list}"
          {:notify_error, _, :update_permission_error, error_list} -> Logger.debug "update_permission_error nil notify: #{inspect error_list}"
          {:notify_error, _, :validation_error, error_list} -> Logger.debug "validation_error nil notify: #{inspect error_list}"
          {:notify_success, _, user} -> Logger.debug "create_user_success: nil notify #{inspect user}"
        end
     end) |> Enum.to_list

    {:noreply, [], state}
  end
end
defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileNotification do
  @moduledoc false
  use GenStage
  require Logger
   def start_link(setup) do
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:consumer, [], subscribe_to: [UserManager.CreateFacebookProfile.CreateFacebookProfileNotificationFormatter]}
  end
  def handle_events(events, from, state) do
    processed_events = events
    |> Flow.from_enumerable()
    |> Flow.map(fn e -> process_notification(e) end)
    |> Enum.to_list
    {:noreply, [], state}
  end
  defp process_notification({:create_user_notify, user_id}) do
    GenServer.cast(UserManager.UserRepo, {:create_user_notify, user_id})
  end
  defp process_notification({:notify_success, :facebook_create_success, token, expire_time, user_id, notify}) do
    Process.send(notify, {:facebook_create_success, token, expire_time, user_id}, [])
  end
  defp process_notification()
  defp process_notification({:notify_error, :access_token_error, response, status_code, user_id, notify}) do
    Process.send(notify, {:error, :access_token_error, response, status_code, user_id}, [])
  end
  defp process_notification({:notify_error, :access_token_missing, response_json, user_id, notify}) do
    Process.send(notify, {:error, :access_token_missing, response_json, user_id}, [])
  end
  defp process_notification({:notify_error, :expire_time_missing, response_json, user_id, notify}) do
    Process.send(notify, {:error, :expire_time_missing, response_json, user_id}, [])
  end
  defp process_notification({:notify_error, :server_token_error, response_json, status_code, user_id, notify}) do
    Process.send(notify, {:error, :server_token_error, response_json, status_code, user_id}, [])
  end
  defp process_notification({:notify_error, :server_token_missing, response_json, user_id, notify}) do
    Process.send(notify, {:error, :server_token_missing, response_json, user_id}, [])
  end
  defp process_notification({:notify_error, :server_expire_time_missing,  user_id, notify}) do
    Process.send(notify, {:error, :server_expire_time_missing, user_id}, [])
  end
  defp process_notification({:notify_error, :repo_error, errors, user_id, notify}) do
    Process.send(notify, {:error, :repo_error, errors, user_id}, notify)
  end
  defp process_notification({:notify_error, :validation_error, errors, user_id, notify}) do
    Process.send(notify, {:error, :validation_error, errors, user_id}, [])
  end
  defp process_notification({:notify_error, :profile_validation_error, errors, user_id, notify}) do
    Process.send(notify, {:error, :profile_validation_error, errors, user_id}, [])
  end
end

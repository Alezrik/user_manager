defmodule UserManager.Notifications.NotificationResponseProcessor do
  @moduledoc false
  use GenServer
  require Logger
  alias UserManager.Struct.NotificationResponse
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  @doc"""

    ask system to process a notification
"""
  def process_notification(workflow, notification_code, notification_metadata, notify) do
    GenServer.cast(UserManager.Notifications.NotificationResponseProcessor, {:process_notification,
              workflow,
              notification_code,
              notification_metadata,
              notify})
  end
  def init(_opts) do
    {:ok, UserManager.Notifications.NotificationRequestInitiator.get_workflow_and_codes_map()}
  end
  def handle_cast({:process_notification, workflow, notification_code, notification_metadata, notify}, state) when is_nil(notify) do
    validate = state
    |> Enum.filter(fn {tag, list} ->
      tag == workflow && Enum.member?(list, notification_code)
    end)
    |> Enum.count
    case validate > 0 do
      true ->
        _process_notify = UserManager.Notifications.NotificationRequestInitiator.get_subscribers(workflow, notification_code)
        |> Flow.from_enumerable()
        |> Flow.map(fn subscribers -> process_subscriber_notification(subscribers, notification_metadata) end)
        |> Enum.to_list
        {:noreply, state}
      false -> Logger.error "Invalid notification request for #{inspect workflow} -> #{inspect notification_code}, validate UserManager.Notifications.NotificationRequestInitiator.get_workflow_and_codes_map()"
    end

  end
  def handle_cast({:process_notification, workflow, notification_code, notification_metadata, notify}, state) do
  validate = state
  |> Enum.filter(fn {tag, list} ->
    tag == workflow && Enum.member?(list, notification_code)
  end)
  |> Enum.count
  case validate > 0 do
    true ->
      _process_notify = UserManager.Notifications.NotificationRequestInitiator.get_subscribers(workflow, notification_code)
      |> Flow.from_enumerable()
      |> Flow.map(fn subscribers -> process_subscriber_notification(subscribers, notification_metadata) end)
      |> Enum.to_list
      _resp = process_notify_request(notification_metadata, workflow, notification_code, notify)
    false -> Logger.error "Invalid notification request for #{inspect workflow} -> #{inspect notification_code}, validate UserManager.Notifications.NotificationRequestInitiator.get_workflow_and_codes_map()"
  end
  {:noreply, state}
  end
  defp process_notify_request(response_metadata, workflow, code, request) do
    send_notification(%NotificationResponse{workflow: workflow,
        notification_type: code, response_parameters: response_metadata,
        session_reference_metadata: request.session_reference_metadata}, request.destination_pid)
  end
  defp process_subscriber_notification({:notify_sub, workflow, workflow_response_code, response_pid}, notification_metadata) do
    response = build_response(workflow, workflow_response_code, notification_metadata)
    send_notification(response, response_pid)
  end
  defp send_notification(_, pid) when is_nil(pid) do

  end
  defp send_notification(response, pid) do
    Process.send(pid, {:notify, response}, [])
  end
  defp build_response(workflow, response, metadata) do
    %NotificationResponse{workflow: workflow, notification_type: response, response_parameters: metadata}
  end
end

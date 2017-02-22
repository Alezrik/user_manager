defmodule UserManager.Notifications.NotificationRequestInitiator do
  @moduledoc """
  receives requests to subscribe to a static notification
"""
  use GenServer
  require Logger
  @doc"""
  list of workflows and the codes that notifications can be configured for
"""
 def get_workflow_and_codes_map() do
    Application.get_env(:user_manager, :notification_workflow_and_codes)
  end
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, []}
  end
  @doc"""
  register a subscriber (pid) to revieve process.send events from the notification service

  ## Attributes
  * workflow - the workflow to subscibe to
  * workflow_response_code - the workfow code to subscibe to

  ## Examples
    iex>{:ok, response} = UserManager.Notifications.NotificationRequestInitiator.register_static_notification(:create_user, :validation_error, self())
    iex>{:notify_sub, w, tag, _} = response
    iex>w
    :create_user
    iex>tag
    :validation_error

    iex>UserManager.Notifications.NotificationRequestInitiator.register_static_notification(:never_find_me, :success, self())
    {:error, :notification_not_found}

    iex>UserManager.Notifications.NotificationRequestInitiator.register_static_notification(:create_user, :not_found_me_ever_never, self())
    {:error, :notification_not_found}

    iex>UserManager.Notifications.NotificationRequestInitiator.register_static_notification(:create_user, :success, nil)
    {:error, :null_pid}
"""
  def register_static_notification(workflow, workflow_response_code, notification_response_pid) do
      GenServer.call(UserManager.Notifications.NotificationRequestInitiator, {:add_static_notification, workflow, workflow_response_code, notification_response_pid})
    end
  @doc"""
  get subscribers for a particular workflow/workflow_response_code

  ## Examples
    iex>{:ok, _} = UserManager.Notifications.NotificationRequestInitiator.register_static_notification(:create_user, :validation_error, self())
    iex>Enum.count(UserManager.Notifications.NotificationRequestInitiator.get_subscribers(:create_user, :validation_error)) == 1
    true

    iex>Enum.count(UserManager.Notifications.NotificationRequestInitiator.get_subscribers(:create_user, :not_found)) == 0
    true
"""
  def get_subscribers(workflow, workflow_response_code) do
    GenServer.call(UserManager.Notifications.NotificationRequestInitiator, {:get_subscribers, workflow, workflow_response_code})
  end

  defp process_notification_sub_list(notification_sub_list) do
    Enum.filter(notification_sub_list, fn {:notify_sub, _, _, pid} -> Process.alive?(pid) end)
  end
  defp validate_new_sub(workflow, workflow_response_code, response_pid) do
   Enum.reduce(get_workflow_and_codes_map(), {:error, :notification_not_found}, fn {w_flow, w_flow_codes_list}, acc ->
    process_reduce({w_flow, w_flow_codes_list}, acc, workflow, workflow_response_code, response_pid)
  end)
  end
  defp process_reduce({w_flow, w_flow_codes_list}, acc, workflow, workflow_response_code, response_pid) do
    case Enum.count(Enum.filter(w_flow_codes_list, fn x ->
    x == workflow_response_code && w_flow == workflow end)) > 0 do
     false -> acc
     true -> process_new_sub({:notify_sub, workflow, workflow_response_code, response_pid})
    end
  end
  defp process_new_sub({:notify_sub, workflow, workflow_response_code, response_pid}) when is_nil(response_pid) do {:error, :null_pid} end
  defp process_new_sub({:notify_sub, workflow, workflow_response_code, response_pid}) do
    case Process.alive?(response_pid) do
      false -> {:error, :invalid_pid}
      true -> {:ok, {:notify_sub, workflow, workflow_response_code, response_pid}}
    end
  end
  def handle_call({:add_static_notification, workflow, workflow_response_code, notification_response_pid}, _from, state) do
   case validate_new_sub(workflow, workflow_response_code, notification_response_pid) do
     {:error, reason} -> {:reply, {:error, reason}, state}
     {:ok, validated} -> {:reply, {:ok, validated}, [validated | process_notification_sub_list(state)]}
    end
  end
  def handle_call({:get_subscribers, workflow, workflow_response_code}, _from, state) do
    {:reply,
    state
    |> Enum.filter(fn {:notify_sub, w_flow, w_response_code, _} -> w_flow == workflow && w_response_code == workflow_response_code end)
    |> Enum.filter(fn {:notify_sub, _, _, pid} -> Process.alive?(pid) end),
    process_notification_sub_list(state)
    }
  end
end

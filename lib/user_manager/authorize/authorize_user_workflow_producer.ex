defmodule UserManager.Authorize.AuthorizeUserWorkflowProducer do
  @moduledoc """
  Producer for the Authorize User Workflow
"""
  use GenStage
  require Logger
  def start_link(setup) do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end
  def init(state) do
    {:producer, {[], 0}}
  end
  def handle_cast({:authorize_token, token, permission_list, require_all, notify}, {queue, demand}) do
    {events_to_send, queued_events} = process_events(demand, queue, {:authorize_token, token, permission_list, require_all, notify})
    {:noreply, events_to_send, queued_events}
  end
  def handle_demand(demand, {queue, d}) when demand > 0 do
    {send_events, new_state} = process_events(demand, queue, nil)
    {:noreply, send_events, new_state}
  end
  defp process_events(demand, [], nil) do
    {[], {[], demand}}
  end
  defp process_events(0, [], new_event) do
    {[], {[new_event], 0}}
  end
  defp process_events(demand, [], new_event) do
    {[new_event], {[], demand - 1}}
  end
  defp process_events(0, items_queue, new_event) do
    {[], {[new_event | items_queue], 0}}
  end
  defp process_events(demand, items_queue, nil) do
    {send_events, queued_events} = Enum.split(Enum.reverse(items_queue), demand)
    {send_events, {queued_events, demand - Enum.count(send_events)}}
  end
  defp process_events(demand, items_queue, new_event) do
    {send_events, queued_events} = Enum.split(Enum.reverse([new_event | items_queue]), demand)
    {send_events, {queued_events, demand - Enum.count(send_events)}}
  end
end
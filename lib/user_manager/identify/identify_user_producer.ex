defmodule UserManager.Identify.IdentifyUserProducer do
  @moduledoc """
  Producer for IdentifyUserWorkflow
"""
    use GenStage
    require Logger
    def start_link(setup) do
      GenStage.start_link(__MODULE__, [], [name: __MODULE__])
    end
    def init(state) do
      {:producer, {[], 0}}
    end
    def handle_cast({:identify_user, token, notify}, {queue, demand}) do
      {send_events, new_state} = process_events(demand, queue, {:identify_user, token, notify})
      {:noreply, send_events, new_state}
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
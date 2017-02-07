defmodule UserManager.UserProfile.CreateUserWorkflowProducer do
  @moduledoc """
  Initiates the CreateUserWorkflow
"""
  use GenStage
  require Logger
  def start_link(setup) do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end
  def init(state) do
    {:producer, {[], 0}}
  end
  def create_user(name, password, notify \\ nil) do

    GenStage.cast(__MODULE__, {:create_user, name, password, notify})
  end
  def handle_cast({:create_user, name, password, notify}, {queue, demand}) do
    {send_events, new_state} = process_events(demand, queue, {:create_user, name, password, notify})
    {:noreply, send_events, new_state}
  end
  def handle_demand(demand, {queue, d}) when demand > 0 do
    Logger.debug "handle demand: #{demand}, queue: #{inspect queue}"
    {send_events, new_state} = process_events(demand, queue, nil)
    {:noreply, send_events, new_state}
  end
  def process_events(demand, [], nil) do
    {[], {[], demand}}
  end
  def process_events(0, [], new_event) do
    {[], {[new_event], 0}}
  end
  def process_events(demand, [], new_event) do
    {[new_event], {[], demand - 1}}
  end
  def process_events(0, items_queue, new_event) do
    {[], {[new_event | items_queue], 0}}
  end
  def process_events(demand, items_queue, nil) do
    {send_events, queued_events} = Enum.split(Enum.reverse(items_queue), demand)
    {send_events, {queued_events, demand - Enum.count(send_events)}}
  end
  def process_events(demand, items_queue, new_event) do
    {send_events, queued_events} = Enum.split(Enum.reverse([new_event | items_queue]), demand)
    {send_events, {queued_events, demand - Enum.count(send_events)}}
  end

end
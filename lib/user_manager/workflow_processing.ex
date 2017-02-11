defmodule UserManager.WorkflowProcessing do
  @moduledoc false

  def get_process_events(events, process_tag) do
    get_events(events, process_tag, true)
  end
  def get_unprocessed_events(events, processed_tag) do
    get_events(events, processed_tag, false)
  end
  def get_events(events, process_tag, match) do

    Enum.filter(events, fn e ->
      (Enum.fetch!(Tuple.to_list(e), 0) == process_tag) == match
    end)
  end
end

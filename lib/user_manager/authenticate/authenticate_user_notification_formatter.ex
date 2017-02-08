defmodule UserManager.Authenticate.AuthenticateUserNotificationFormatter do
  @moduledoc false
  use GenStage
  alias UserManager.Repo
  require Logger
   def start_link(setup) do
         name = "#{__MODULE__}#{setup}"
         GenStage.start_link(__MODULE__, [], name: __MODULE__)
     end
  def init(stat) do

    {:producer_consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserTokenGenerate]}
  end
  def handle_events(events, from, state) do
    format_events = events
    |> Flow.from_enumerable
    |> Flow.flat_map(fn e ->
        case e do
          {:ok, nil, _} -> []
          {:user_not_found_error, nil} -> []
          {:authenticate_failure, nil} -> []
          {:token_storage_failure, nil} -> []
          {:token_error, nil, _} -> []
          {:ok, notify, token} -> [{:notify_success, :authentication, notify, token}]
          {:user_not_found_error, notify} -> [{:notify_error, :user_not_found, notify}]
          {:authenticate_failure, notify} -> [{:notify_error, :authenticate_failure, notify}]
          {:token_storage_failure, notify} -> [{:notify_error, :token_storage_failure, notify}]
          {:token_error, notify, reason} -> [{:notify_error, :authenticate_token_error, notify, reason}]
        end

     end)
    |> Enum.to_list
    {:noreply, format_events, state}
  end
end
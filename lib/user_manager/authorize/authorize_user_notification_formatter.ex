defmodule UserManager.Authorize.AuthorizeUserNotificationFormatter do
  @moduledoc false
    use GenStage
    alias UserManager.Repo
    require Logger
     def start_link(setup) do
           name = "#{__MODULE__}#{setup}"
           GenStage.start_link(__MODULE__, [], name: __MODULE__)
       end
    def init(stat) do

      {:producer_consumer, [], subscribe_to: [UserManager.Authorize.AuthorizeUserValidatePermissions]}
    end
    def handle_events(events, from, state) do
      format_events = events
      |> Flow.from_enumerable
      |> Flow.flat_map(fn e ->
          case e do
            {:ok, nil} -> []
            {:error, :token_decode_error, _, nil} -> []
            {:error, :token_not_found, nil} -> []
            {:notify_error, :unauthorized, nil} -> []
            {:ok, notify} -> [{:notify_success, :authorize_user, notify}]
            {:error, :token_decode_error, reason, notify} -> [{:notify_error, :token_decode_error, notify, reason}]
            {:error, :token_not_found, notify} -> [{:notify_error, :token_not_found, notify}]
            {:error, :unauthorized, notify} -> [{:notify_error, :unauthorized, notify}]
          end
      end)
      |> Enum.to_list
      {:noreply, format_events, state}
    end
end

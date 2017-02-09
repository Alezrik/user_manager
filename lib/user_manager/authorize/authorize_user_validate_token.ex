defmodule UserManager.Authorize.AuthorizeUserValidateToken do
  @moduledoc false
  use GenStage
  alias UserManager.Schemas.User
  require Logger
   def start_link(setup) do
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:producer_consumer, [], subscribe_to: [UserManager.Authorize.AuthorizeUserWorkflowProducer]}
  end
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.map(fn {:authorize_token, token, permission_list, require_all, notify}  ->
      case Guardian.decode_and_verify(token) do
        {:error, :token_not_found} -> {:error, :token_not_found, notify}
        {:error, reason} -> {:error, :token_decode_error, reason, notify}
        {:ok, data} -> {:validate_permissions, data, permission_list, require_all, notify}
      end
     end)
     |> Enum.to_list
     {:noreply, process_events, state}
   end
  
end
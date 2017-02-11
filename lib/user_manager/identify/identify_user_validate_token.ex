defmodule UserManager.Identify.IdentifyUserValidateToken do
  @moduledoc false
    use GenStage
    alias UserManager.User
    require Logger
     def start_link(setup) do
        name = "#{__MODULE__}#{setup}"
        GenStage.start_link(__MODULE__, [], name: __MODULE__)
    end
    def init(stat) do
      {:producer_consumer, [], subscribe_to: [UserManager.Identify.IdentifyUserProducer]}
    end
    def handle_events(events, from, state) do

      process_events = events
      |> Flow.from_enumerable
      |> Flow.map(fn {:identify_user, token, notify}  ->
        case Guardian.decode_and_verify(token) do
          {:error, :token_not_found} -> {:error, :token_not_found, notify}
          {:error, reason} -> {:error, :token_decode_error, reason, notify}
          {:ok, data} -> {:deserialize_user, data, notify}
        end
       end)
       |> Enum.to_list
       {:noreply, process_events, state}
     end
end

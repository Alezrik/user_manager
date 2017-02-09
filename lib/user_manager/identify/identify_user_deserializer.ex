defmodule UserManager.Identify.IdentifyUserDeserializer do
  @moduledoc false
  use GenStage
      alias UserManager.User
      require Logger
       def start_link(setup) do
          name = "#{__MODULE__}#{setup}"
          GenStage.start_link(__MODULE__, [], name: __MODULE__)
      end
      def init(stat) do
        {:producer_consumer, [], subscribe_to: [UserManager.Identify.IdentifyUserValidateToken]}
      end
      def handle_events(events, from, state) do

        process_events = events
        |> Enum.filter(fn  e ->
          case e do
            {:deserialize_user, data, notify} -> true
            other -> false
          end
        end)
        |> Flow.from_enumerable
        |> Flow.map(fn {:deserialize_user, data, notify} ->
          case UserManager.GuardianSerializer.from_token(Map.fetch!(data, "sub")) do
                {:ok, user} -> {:ok, user, notify}
                other -> {:error, :user_deserialize_error, notify}
          end
        end)
        |> Enum.to_list
        un_processed_events = events
        |> Enum.filter(fn  e ->
          case e do
            {:deserialize_user, data, notify} -> false
            other -> true
          end
        end)
        {:noreply, process_events ++ un_processed_events, state}
      end
  
end
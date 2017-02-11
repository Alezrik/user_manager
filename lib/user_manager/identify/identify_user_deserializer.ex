defmodule UserManager.Identify.IdentifyUserDeserializer do
  @moduledoc false
  use GenStage
      alias UserManager.Schemas.User
      require Logger
       def start_link(setup) do
          name = "#{__MODULE__}#{setup}"
          GenStage.start_link(__MODULE__, [], name: __MODULE__)
      end
      def init(stat) do
        {:producer_consumer, [], subscribe_to: [UserManager.Identify.IdentifyUserValidateToken]}
      end
      def handle_events(events, from, state) do

        process_events =  events |> UserManager.WorkflowProcessing.get_process_events(:deserialize_user)
        |> Flow.from_enumerable
        |> Flow.map(fn {:deserialize_user, data, notify} ->
          case UserManager.GuardianSerializer.from_token(Map.fetch!(data, "sub")) do
                {:ok, user} -> {:ok, user, notify}
                other -> {:error, :user_deserialize_error, notify}
          end
        end)
        |> Enum.to_list
        un_processed_events =  UserManager.WorkflowProcessing.get_unprocessed_events(events, :deserialize_user)
        {:noreply, process_events ++ un_processed_events, state}
      end
end

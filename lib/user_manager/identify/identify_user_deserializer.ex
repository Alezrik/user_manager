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
      @doc"""
      get user from the decoded token

      ## Examples
        iex>{:ok, usr} = UserManager.UserManagerApi.create_user(Faker.Name.first_name <> Faker.Name.last_name, "testpassword", Faker.Internet.email)
        iex>usr_id = "User:" <> Integer.to_string(usr.id)
        iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserDeserializer.handle_events( [{:deserialize_user, %{"sub"=>usr_id}, nil}], nil, [])
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
        :ok

        iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserDeserializer.handle_events( [{:deserialize_user, %{"sub"=>"fdsafdsa"}, nil}], nil, [])
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
        :error
        iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
        :user_deserialize_error
"""
      def handle_events(events, from, state) do
        process_events =  events |> UserManager.WorkflowProcessing.get_process_events(:deserialize_user)
        |> Flow.from_enumerable
        |> Flow.map(fn e -> process_event(e) end)
        |> Enum.to_list
        un_processed_events =  UserManager.WorkflowProcessing.get_unprocessed_events(events, :deserialize_user)
        {:noreply, process_events ++ un_processed_events, state}
      end

      defp process_event({:deserialize_user, data, notify}) do
        case UserManager.GuardianSerializer.from_token(Map.fetch!(data, "sub")) do
              {:ok, user} -> {:ok, user, notify}
              other -> {:error, :user_deserialize_error, notify}
        end
      end
end

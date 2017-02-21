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
        {:consumer, [], subscribe_to: [UserManager.Identify.IdentifyUserValidateToken]}
      end
      @doc"""
      get user from the decoded token

      ## Examples
        iex>{:notify, response} = UserManager.UserManagerApi.create_user(Faker.Name.first_name <> Faker.Name.last_name, "testpassword", Faker.Internet.email)
        iex>metadata = response.response_parameters
        iex>usr = Map.fetch!(metadata, "created_object")
        iex>usr_id = "User:" <> Integer.to_string(usr.id)
        iex>UserManager.Identify.IdentifyUserDeserializer.handle_events( [{:deserialize_user, %{"sub"=>usr_id}, nil}], nil, [])
        {:noreply, [], []}

        iex>UserManager.Identify.IdentifyUserDeserializer.handle_events( [{:deserialize_user, %{"sub"=>"fdsafdsa"}, nil}], nil, [])
        {:noreply, [], []}

"""
      def handle_events(events, from, state) do
        process_events =  events
        |> Flow.from_enumerable
        |> Flow.flat_map(fn e -> process_event(e) end)
        |> Enum.to_list
        {:noreply, [], state}
      end

      defp process_event({:deserialize_user, data, notify}) do
        case UserManager.GuardianSerializer.from_token(Map.fetch!(data, "sub")) do
              {:ok, user} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:identify_user, :success, %{"user" => user}, notify)
                            []
              other -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:identify_user, :user_deserialize_error, %{}, notify)
                       []
        end
      end
end

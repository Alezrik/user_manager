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
    @doc"""
    validate user token

    ## Examples
      iex>name = Faker.Name.first_name <> Faker.Name.last_name
      iex>{:notify, response} = UserManager.UserManagerApi.create_user(name, "fdsafdsfasfdsa", Faker.Internet.email)
      iex>metadata = response.response_parameters
      iex>user = Map.fetch!(metadata, "created_object")
      iex>{:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "fdsafdsfasfdsa")
      iex>token = Map.fetch!(response.response_parameters, "authenticate_token")
      iex>{:noreply, response, _} = UserManager.Identify.IdentifyUserValidateToken.handle_events([{:identify_user, token, nil}], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
      :deserialize_user

      iex>UserManager.Identify.IdentifyUserValidateToken.handle_events([{:identify_user, "fsfsafas", nil}], nil, [])
      {:noreply, [], []}

      iex>token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjQiLCJleHAiOjE0ODkzMDMyMTksImlhdCI6MTQ4NjcxMTIxOSwiaXNzIjoiU29tZW9uZSIsImp0aSI6Ijg0NGUwY2EzLWM4ZWUtNDQ3Mi1iMzYxLWVhODdjNGUzYjU3NCIsInBlbSI6eyJkZWZhdWx0IjoxfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYnJvd3NlciJ9.nA3-dkFNqTW1GYO8x1v9zTQoUk6ddyK2FqgZPZk9k6lO_iIOQx6We35ItLEeRAZO_5lv9JR4WWizQ7J7p8HRcA"
      iex>UserManager.Identify.IdentifyUserValidateToken.handle_events([{:identify_user, token, nil}], nil, [])
      {:noreply, [], []}
"""
    def handle_events(events, from, state) do
      process_events = events
      |> Flow.from_enumerable
      |> Flow.flat_map(fn e  -> process_event(e) end)
      |> Enum.to_list
      {:noreply, process_events, state}
    end
    defp process_event({:identify_user, token, notify}) do
      case Guardian.decode_and_verify(token) do
        {:error, :token_not_found} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:identify_user, :token_not_found, %{}, notify)
                                      []
        {:error, reason} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:identify_user, :token_decode_error, UserManager.Notifications.NotificationMetadataHelper.build_token_decode_error(reason), notify)
                            []
        {:ok, data} -> [{:deserialize_user, data, notify}]
      end
    end
end

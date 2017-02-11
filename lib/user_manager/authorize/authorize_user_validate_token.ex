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
  @doc"""
  decode and verify user token

  ## Examples

      iex>name = Faker.Name.first_name <> Faker.Name.last_name
      iex>email = Faker.Internet.email
      iex>{:ok, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
      iex>{:ok, token} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
      iex>msg = {:authorize_token, token, [], true, nil}
      iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)),0)
      :validate_permissions

      iex>msg = {:authorize_token, "fskafsakjfkasfd", [], true, nil}
      iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)),0)
      :error
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
      :token_decode_error

      iex>token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjQiLCJleHAiOjE0ODkzMDMyMTksImlhdCI6MTQ4NjcxMTIxOSwiaXNzIjoiU29tZW9uZSIsImp0aSI6Ijg0NGUwY2EzLWM4ZWUtNDQ3Mi1iMzYxLWVhODdjNGUzYjU3NCIsInBlbSI6eyJkZWZhdWx0IjoxfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYnJvd3NlciJ9.nA3-dkFNqTW1GYO8x1v9zTQoUk6ddyK2FqgZPZk9k6lO_iIOQx6We35ItLEeRAZO_5lv9JR4WWizQ7J7p8HRcA"
      iex>msg = {:authorize_token, token, [], true, nil}
      iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)),0)
      :error
      iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
      :token_not_found

"""
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

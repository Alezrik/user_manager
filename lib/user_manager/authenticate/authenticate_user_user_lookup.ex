defmodule UserManager.Authenticate.AuthenticateUserUserLookup do
  @moduledoc false
  use GenStage
  require Logger
  alias UserManager.Schemas.User
  alias UserManager.Schemas.UserProfile
  alias UserManager.Repo
  import Ecto.Query
  def start_link(setup) do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end
  def init(state) do
    {:producer_consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserWorkflowProducer]}
  end
  @doc"""
  get event from workflow producer

  Input: {:authenticate_user, name, password, source, notify}

  Output:
    {:user_not_found_error, notify}
    {:validate_user, user, password, source, notify}

  ## Examples:
    iex> name = Faker.Name.first_name <> Faker.Name.last_name
    iex> {:ok, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", "here@there.com")
    iex> {:noreply, response, _state} = UserManager.Authenticate.AuthenticateUserUserLookup.handle_events([{:authenticate_user, name, "secretpassword", :browser, nil}], self(), [])
    iex> Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :validate_user

    iex> {:noreply, response, _state} = UserManager.Authenticate.AuthenticateUserUserLookup.handle_events([{:authenticate_user, "someothername", "secretpassword", :browser, nil}], self(), [])
    iex> Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :user_not_found_error
"""
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.map(fn e ->
       {:authenticate_user, name, password, source, notify} = e
        case UserProfile
        |> where(name: ^name)
        |> Repo.one do
          nil -> {:user_not_found_error, notify}
          user_profile ->
          profile =  Repo.preload(user_profile, :user)
           u =  Repo.preload(profile.user, :user_profile)
          {:validate_user, u, password, source, notify}
        end
     end)
     |> Enum.to_list
     {:noreply, process_events, state}
  end
end

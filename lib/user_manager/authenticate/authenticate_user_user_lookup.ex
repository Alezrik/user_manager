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

    iex> UserManager.Authenticate.AuthenticateUserUserLookup.handle_events([{:authenticate_user, "fdsafdsa", "fdsafdsa", :browser, nil}], self(), [])
    {:noreply, [user_not_found_error: nil], []}
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

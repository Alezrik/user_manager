defmodule UserManager.Authenticate.AuthenticateUserValidation do
  @moduledoc false
  use GenStage
  require Logger
  alias UserManager.Schemas.User
  alias UserManager.Repo
  import Ecto.Query
  alias Comeonin.Bcrypt
  def start_link(setup) do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end
  def init(state) do
    {:producer_consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserUserLookup]}
  end
  def handle_events(events, from, state) do
    process_events = events
    |> Enum.filter(fn e -> case e do
        {:validate_user, user, password, source, notify} -> true
        other -> false
      end
    end)
    |> Flow.from_enumerable
    |> Flow.map(fn {:validate_user, user, password, source, notify} ->
        case Bcrypt.checkpw(password, user.user_profile.password) do
          true -> {:authenticate_user, user, source, notify}
          false -> {:authenticate_failure, notify}
        end
     end)
     |> Enum.to_list

     un_processed_events = events
     |> Enum.filter(fn e -> case e do
          {:validate_user, user, password, source, notify} -> false
          other -> true
        end
      end)
      {:noreply, process_events ++ un_processed_events, state}
  end
end
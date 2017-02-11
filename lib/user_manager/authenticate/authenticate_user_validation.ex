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
    process_events = events |> UserManager.WorkflowProcessing.get_process_events(:validate_user)
    |> Flow.from_enumerable
    |> Flow.map(fn {:validate_user, user, password, source, notify} ->
      authenticate_user(password, user.user_profile.password, user, source, notify)
     end)
     |> Enum.to_list
     un_processed_events = UserManager.WorkflowProcessing.get_unprocessed_events(events, :validate_user)
      {:noreply, process_events ++ un_processed_events, state}
  end
  defp authenticate_user(input_password, encrypted_password, user, source, notify) do
    case Bcrypt.checkpw(input_password, encrypted_password) do
      true -> {:authenticate_user, user, source, notify}
      false -> {:authenticate_failure, notify}
    end
  end

end

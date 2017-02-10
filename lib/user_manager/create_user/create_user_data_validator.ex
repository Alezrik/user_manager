defmodule UserManager.CreateUser.CreateUserDataValidator do
  @moduledoc false
  use GenStage
  alias UserManager.Schemas.User
  alias UserManager.Schemas.UserProfile
  import Ecto.Changeset
  require Logger
   def start_link(setup) do
      name = "#{__MODULE__}#{setup}"
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:producer_consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserWorkflowProducer]}
  end
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.map(fn {:create_user, name, password, email, notify}  ->
     user_profile_changeset = UserProfile.changeset(%UserProfile{}, %{"name" => name, "password" => password, "email" => email})
     case user_profile_changeset.valid? do
       true -> get_user_changeset(user_profile_changeset, notify)
        false -> {:validation_error, user_profile_changeset.errors, notify}
     end
     end)
     |> Enum.to_list
    {:noreply, process_events, state}
  end

  defp get_user_changeset(user_profile_changeset, notify) do
    user = %User{} |> User.changeset(%{}) |> put_assoc(:user_profile, user_profile_changeset)
      case user.valid? do
        true -> {:insert_user, user, notify}
        false -> {:validation_error, user.errors, notify}
      end
  end
end
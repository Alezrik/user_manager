defmodule UserManager.CreateUser.CreateUserDataValidator do
  @moduledoc false
  use GenStage
  alias UserManager.Schemas.UserSchema
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
  @doc"""

  responsible for validating input to create a user

  Examples:

    iex>{:noreply, response, _} = UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "validusername", "validpassword", "email@here.com", nil}], nil, [])
    iex> assert Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :insert_user

    iex>{:noreply, response, _} = UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "", "validpassword", "email@here.com", nil}], nil, [])
    iex> assert Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :validation_error

    iex>{:noreply, response, _} = UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "validusername", "", "email@here.com", nil}], nil, [])
    iex> assert Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :validation_error

    iex>{:noreply, response, _} = UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "validusername", "validpassword", "", nil}], nil, [])
    iex> assert Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :validation_error

"""
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.map(fn {:create_user, name, password, email, notify}  ->
     user_profile_changeset = UserProfile.changeset(%UserProfile{}, %{"authentication_metadata" => %{"credentials" => %{"name" => name, "password" => password, "email" => email}}})
     case user_profile_changeset.valid? do
       true -> get_user_changeset(user_profile_changeset, notify)
        false -> {:validation_error, user_profile_changeset.errors, notify}
     end
     end)
     |> Enum.to_list
    {:noreply, process_events, state}
  end

  defp get_user_changeset(user_profile_changeset, notify) do
    user = %UserSchema{} |> UserSchema.changeset(%{}) |> put_assoc(:user_profile, user_profile_changeset)
      case user.valid? do
        true -> {:insert_user, user, notify}
        false -> {:validation_error, user.errors, notify}
      end
  end
end

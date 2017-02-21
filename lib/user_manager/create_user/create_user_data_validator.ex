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

    iex>UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "", "validpassword", "email@here.com", nil}], nil, [])
    {:noreply, [], []}

    iex>UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "validusername", "", "email@here.com", nil}], nil, [])
    {:noreply, [], []}

    iex>UserManager.CreateUser.CreateUserDataValidator.handle_events([{:create_user, "validusername", "validpassword", "", nil}], nil, [])
    {:noreply, [], []}
"""
  def handle_events(events, from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.flat_map(fn e -> process_event(e) end)
     |> Enum.to_list
    {:noreply, process_events, state}
  end
  defp process_event({:create_user, name, password, email, notify}) do
     user_profile_changeset = UserProfile.changeset(%UserProfile{}, %{"authentication_metadata" => %{"credentials" => %{"name" => name, "password" => password, "email" => email}}})
     case user_profile_changeset.valid? do
       true -> get_user_changeset(user_profile_changeset, notify)
        false -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_user, :validation_error, UserManager.Notifications.NotificationMetadataHelper.build_changeset_validation_error(:user_profile, user_profile_changeset), notify)
                []
     end
  end
  defp get_user_changeset(user_profile_changeset, notify) do
    user = %UserSchema{} |> UserSchema.changeset(%{}) |> put_assoc(:user_profile, user_profile_changeset)
      case user.valid? do
        true -> [{:insert_user, user, notify}]
        false -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_user, :validation_error, UserManager.Notifications.NotificationMetadataHelper.build_changeset_validation_error(:user, user), notify)#{:validation_error, user.errors, notify}
              []
      end
  end
end

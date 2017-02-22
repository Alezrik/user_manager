defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileRepoUpdate do
   @moduledoc false
    use GenStage
    alias UserManager.Schemas.UserProfile
    alias UserManager.Schemas.UserSchema
    alias UserManager.Repo
    import Ecto.Query
    require Logger
    def start_link(_) do
        GenStage.start_link(__MODULE__, [], name: __MODULE__)
    end
    def init(_) do
        {:consumer, [], subscribe_to: [UserManager.CreateFacebookProfile.CreateFacebookProfileGenerateServerToken]}
    end

    @facebook_proxy Application.get_env(:user_manager, :facebook_proxy)

    def handle_events(events, _from, state) do
      process_events = events
      |> Flow.from_enumerable
      |> Flow.map(fn e -> process_event(e) end)
      |> Flow.flat_map(fn e -> verify_record(e) end)
      |> Flow.flat_map(fn e -> write_record(e) end)
      |> Enum.to_list
      {:noreply, process_events, state}
    end
    def write_record({:write_record, user_profile_changeset, token, expire_time, _user_id, notify}) do
      case Repo.update(user_profile_changeset) do
        {:error, changeset} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :validation_error, UserManager.Notifications.NotificationMetadataHelper.build_changeset_validation_error(:user_profile, changeset), notify)#{:repo_error, changeset, user_id, notify}
                                []
        {:ok, _item} ->
        UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :success, %{"token" => token, "token_expire_time" => expire_time}, notify)
        []
      end
    end
    def process_event({:process_server_token, token, expire_time , server_token, server_token_expire, user_id, notify}) do
      case GenServer.call(UserManager.UserRepo, {:get_profile_id_for_user_id, user_id}) do
        {:user_not_found} -> {:user_not_found_error, user_id, notify}
        {id} ->
          _profile = UserProfile
          |> where(id: ^id)
          |> Repo.one
          res = @facebook_proxy.get_me("id,email,name", server_token)
          facebook_data = %{"facebook" => %{"name" => Map.fetch!(res, "name"), "email" => Map.fetch!(res, "email"), "id" => Map.fetch!(res, "id"), "expire" => Integer.to_string(server_token_expire), "token" => server_token}}
          {:verify_record, facebook_data, token, expire_time, user_id, notify}
      end
    end
    def verify_record({:verify_record, facebook_data, token, expire_time, user_id, notify}) do
      user = UserSchema
      |> where(id: ^user_id)
      |> Repo.one!
      |> Repo.preload(:user_profile)
      metadata = Map.merge(user.user_profile.authentication_metadata, facebook_data)
      user_profile_changeset = UserProfile.changeset(user.user_profile, %{"authentication_metadata" => metadata})
      case user_profile_changeset.valid? do
        true -> [{:write_record, user_profile_changeset, token, expire_time, user_id, notify}]
        false -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :validation_error, UserManager.Notifications.NotificationMetadataHelper.build_changeset_validation_error(:user_profile, user_profile_changeset), notify)
        #{:profile_validation_error, user_profile_changeset.errors, user_id, notify}
      end
    end
end

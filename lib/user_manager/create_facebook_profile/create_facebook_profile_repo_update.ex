defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileRepoUpdate do
   @moduledoc false
    use GenStage
    alias UserManager.Schemas.UserProfile
    alias UserManager.Schemas.UserSchema
    alias UserManager.Repo
    import Ecto.Query
    require Logger
    def start_link(setup) do
        GenStage.start_link(__MODULE__, [], name: __MODULE__)
    end
    def init(stat) do
        {:producer_consumer, [], subscribe_to: [UserManager.CreateFacebookProfile.CreateFacebookProfileGenerateServerToken]}
    end

    @facebook_proxy Application.get_env(:user_manager, :facebook_proxy)

    def handle_events(events, from, state) do
      process_events = events |> UserManager.WorkflowProcessing.get_process_events(:process_server_token)
      |> Flow.from_enumerable
      |> Flow.map(fn e -> process_event(e) end)
      |> Flow.map(fn e -> verify_record(e) end)
      |> Flow.map(fn e -> write_record(e) end)
      |> Enum.to_list
      unprocessed_events = UserManager.WorkflowProcessing.get_unprocessed_events(events, :process_server_token)
      {:noreply, process_events ++ unprocessed_events, state}
    end
    def write_record({:validation_error, errors, user_id, notify}) do
      {:validation_error, errors, user_id, notify}
    end
    def write_record({:write_record, user_profile_changeset, token, expire_time, user_id, notify}) do
      case Repo.update(user_profile_changeset) do
        {:error, changeset} -> {:repo_error, changeset, user_id, notify}
        {:ok, item} ->
        {:facebook_create_success, token, expire_time, user_id, notify}
      end
    end
    def process_event({:process_server_token, token, expire_time , server_token, server_token_expire, user_id, notify}) do
      case GenServer.call(UserManager.UserRepo, {:get_profile_id_for_user_id, user_id}) do
        {:user_not_found} -> {:user_not_found_error, user_id, notify}
        {id} ->
          profile = UserProfile
          |> where(id: ^id)
          |> Repo.one
          current_metadata = profile.authentication_metadata
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
        true -> {:write_record, user_profile_changeset, token, expire_time, user_id, notify}
        false -> {:profile_validation_error, user_profile_changeset.errors, user_id, notify}
      end
    end
end

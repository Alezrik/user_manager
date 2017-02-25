defmodule UserManager.UserQueryRepo do
  @moduledoc false
  use GenServer
  require Logger
  require Amnesia
  require Amnesia.Helper
  alias UserManager.Repo
  use Database
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  def init(_opts) do
    {:ok, %{}}
  end
  def handle_info({:notify, notification}, state) do
    case notification.notification_type do
      :update ->
       Logger.debug "## update: #{inspect notification}"
       user = Map.fetch!(notification.response_parameters, "user")
       update = user |> update_user_record() |> update_facebook_record(user)
       Logger.debug "## update complete: #{inspect update}"
       {:noreply, state}
      :delete ->
        Logger.debug "## delete: #{inspect notification}"
        user = Map.fetch!(notification.response_parameters, "id")
        {:noreply, state}
      :create ->
        Logger.debug "## create: #{inspect notification}"
        user = Map.fetch!(notification.response_parameters, "user")
        insert = create_user(user)
        Logger.debug "## create insert: #{inspect insert}"
        {:noreply, state}
    end
  end
  defp delete_user_record(user_schema_id) do

  end
  defp update_user_record(user) do
    existing_list = Amnesia.transaction do
      selection = UserProfileDatabase.where user_schema_id == user.id
      Amnesia.Selection.values(selection)
    end
    existing = case existing_list do
      [] -> %UserProfileDatabase{user_schema_id: user.id}
      item -> Enum.at(existing_list, 0)
    end
    u = user |> Repo.preload(:user_profile)
    case u.user_profile == nil do
      true -> user
      false ->
        name = u.user_profile.authentication_metadata |> Map.get("credentials", %{}) |> Map.get("name", "")
        secretkey = u.user_profile.authentication_metadata |> Map.get("credentials", %{}) |> Map.get("secretkey", "")
        email = u.user_profile.authentication_metadata |> Map.get("credentials", %{}) |> Map.get("email", "")
        update_record = Map.merge(existing, %{:name => name, :secretkey => secretkey, :email => email})
        Logger.debug "update record: #{inspect update_record}"
        update = Amnesia.transaction do
          UserProfileDatabase.write(update_record)
        end
        Logger.debug "existing to update: #{inspect update}"
        update
    end

  end
  defp update_facebook_record(_user_profile_record, user) do
    existing_list = Amnesia.transaction do
      selection = FacebookProfileDatabase.where user_schema_id == user.id
      Amnesia.Selection.values(selection)
    end
    existing = case existing_list do
      [] -> %FacebookProfileDatabase{user_schema_id: user.id}
      item -> Enum.at(existing_list, 0)
    end
    u = user |> Repo.preload(:user_profile)
    case u.user_profile == nil do
      true -> user
      false ->
        name = u.user_profile.authentication_metadata |> Map.get("facebook", %{}) |> Map.get("name", "")
        id = u.user_profile.authentication_metadata |> Map.get("facebook", %{}) |> Map.get("id", "")
        email = u.user_profile.authentication_metadata |> Map.get("facebook", %{}) |> Map.get("email", "")
        token = u.user_profile.authentication_metadata |> Map.get("facebook", %{}) |> Map.get("token", "")
        expire = u.user_profile.authentication_metadata |> Map.get("facebook", %{}) |> Map.get("expire", "")
        update_record = Map.merge(existing, %{:name => name, :facebook_id => id, :email => email, :token => token,
                                              :expire => expire})
        update = Amnesia.transaction do
          FacebookProfileDatabase.write(update_record)
        end
        Logger.debug "facebook update: #{inspect update}"
        update

    end

  end
  defp create_user(user) do
   use Database
    Amnesia.transaction do
      %UserDatabase{user_schema_id: user.id} |> UserDatabase.write
    end
  end
end
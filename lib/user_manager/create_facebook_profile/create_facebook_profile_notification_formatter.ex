defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileNotificationFormatter do
  @moduledoc false
  use GenStage
  alias UserManager.Schemas.User
  require Logger
   def start_link(setup) do
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:producer_consumer, [], subscribe_to: [UserManager.CreateFacebookProfile.CreateFacebookProfileRepoUpdate]}
  end
  def handle_events(events, from, state) do
    processed_events = events
    |> Flow.from_enumerable()
    |> Flow.flat_map(fn e -> get_notifications(e) end)
    |> Enum.to_list
    {:noreply, processed_events, state}
  end
  def get_notifications({:facebook_create_success, token, expire_time, user_id, nil}) do
    [{:create_user_notify, user_id}]
  end
  def get_notifications({:facebook_create_success, token, expire_time, user_id, notify}) do
    [{:create_user_notify, user_id}, {:notify_success, :facebook_create_success, token, expire_time, user_id, notify}]
  end
  def get_notifications({:access_token_error, response, status_code, user_id, nil}) do
    []
  end
  def get_notifications({:access_token_error, response, status_code, user_id, notify}) do
    [{:notify_error, :access_token_error, response, status_code, user_id, notify}]
  end
  def get_notifications({:access_token_missing, response_json, user_id, nil}) do
    []
  end
  def get_notifications({:access_token_missing, response_json, user_id, notify}) do
    [{:notify_error, :access_token_missing, response_json, user_id, notify}]
  end
  def get_notifications({:expire_time_missing, response_json, user_id, nil}) do
    []
  end
  def get_notifications({:expire_time_missing, response_json, user_id, notify}) do
    [{:notify_error, :expire_time_missing, response_json, user_id, notify}]
  end
  def get_notifications({:server_token_error, token, expire_time, response_json, status_code, user_id, nil}) do
    []
  end
  def get_notifications({:server_token_error, token, expire_time, response_json, status_code, user_id, notify}) do
    {:notify_error, :server_token_error, response_json, status_code, user_id, notify}
  end
  def get_notifications({:server_token_missing, token, expire_time, response_json, user_id, nil}) do
    []
  end
  def get_notifications({:server_token_missing, token, expire_time, response_json, user_id, notify}) do
    [{:notify_error, :server_token_missing, response_json, user_id, notify}]
  end
  def get_notifications({:expire_time_missing, token, expire_time, response_json, user_id, nil}) do
    []
  end
  def get_notifications({:expire_time_missing, token, expire_time, response_json, user_id, notify}) do
    [{:notify_error, :server_expire_time_missing,  user_id, notify}]
  end
  def get_notifications({:repo_error, changeset, user_id, nil}) do
    []
  end
  def get_notifications({:repo_error, changeset, user_id, notify}) do
    [{:notify_error, :repo_error, changeset.errors, user_id, notify}]
  end
  def get_notifications({:validation_error, errors, user_id, nil}) do
    []
  end
  def get_notifications({:validation_error, errors, user_id, notify}) do
    [{:notify_error, :validation_error, errors, user_id, notify}]
  end
  def get_notifications({:profile_validation_error, errors, user_id, nil}) do
    []
  end
  def get_notifications({:profile_validation_error, errors, user_id, notify}) do
    [{:notify_error, :profile_validation_error, errors, user_id, notify}]
  end
end

defmodule UserManager.Notifications.NotificationMetadataHelper do
  @moduledoc false

  def build_changeset_validation_error(changeset_type, changeset) do
   %{"changeset_type" => changeset_type, "changeset" => changeset}
  end
  def build_create_user_success(user) do
    %{"created_type" => :user_schema, "created_object" => user}
  end
  def build_token_decode_error(message) do
    %{"decode_error" => message}
  end
  def build_facebook_api_error(status_code, response) do
    %{"http_status_code" => status_code, "http_response" => response}
  end
  def build_facebook_access_token_validation_error(reason, json) do
    %{"json_validation_error" => reason, "json" => json}
  end
  def build_facebook_server_token_validation_error(reason, json, access_token, access_token_expire_time) do
    %{"json_validation_error" => reason, "json" => json, "access_token" => access_token, "access_token_expire_time" => access_token_expire_time}
  end
end

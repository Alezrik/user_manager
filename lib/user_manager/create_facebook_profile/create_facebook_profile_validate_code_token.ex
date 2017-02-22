defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileValidateCodeToken do
  @moduledoc false
  use GenStage
  require Logger
  def start_link(_) do
     GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(_) do
    {:producer_consumer, [], subscribe_to: [UserManager.CreateFacebookProfile.CreateFacebookProfileProducer]}
  end

  @facebook_proxy Application.get_env(:user_manager, :facebook_proxy)

  @doc """
  get short term access code from code token

  ## Example return response object
    %HTTPoison.Response{body: "{\"access_token\":\"EAASYcMvboacBAAfdsafasfopTU8ENgOxP4Xqvgrb7hHTjGqpAPXD4xNqIuix2fsaGBFFKKGd8gIo6CAtwZBfrmwmC7ZBUPW0lScciqQAvvsMpBSAjVF9AUhss8KYGP88gZDZD\",
    \"token_type\":\"bearer\",\"expires_in\":5174680}",
    headers: [{"Access-Control-Allow-Origin", "*"}, {"Pragma", "no-cache"},
    {"Cache-Control", "private, no-cache, no-store, must-revalidate"},
    {"facebook-api-version", "v2.8"},
    {"Expires", "Sat, 01 Jan 2000 00:00:00 GMT"},
    {"Content-Type", "application/json; charset=UTF-8"},
    {"x-fb-trace-id", "GOVgujv1ATE"},
    {"x-fb-rev", "2828561"}, {"Vary", "Accept-Encoding"}, {"X-FB-Debug", "Hg0+TaDInvdBLTvHAhTJ3hsuuyjeA//nmrchMjHd0y2j789EjeMb++tKuWYFAzM3RerxXvAOMVQoeF2yBdw7VA=="},
    {"Date", "Mon, 13 Feb 2017 08:02:30 GMT"}, {"Transfer-Encoding", "chunked"}, {"Connection", "keep-alive"}], status_code: 200}
"""
  def handle_events(events, _from, state) do
    process_events = events
    |> Flow.from_enumerable()
    |> Flow.flat_map(fn e -> process_event(e) end)
    |> Flow.flat_map(fn e -> parse_access_token(e) end)
    |> Enum.to_list
    {:noreply, process_events, state}
  end
  defp process_event({:create_facebook_profile, code_token, user_id, notify}) do
    {response, status_code} = @facebook_proxy.get_access_key_from_code(code_token)
    case status_code == 200 do
      true ->
      response_json = Poison.Parser.parse!(response)
      [{:parse_access_token, response_json, user_id, notify}]
      false ->
        UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :access_token_error, UserManager.Notifications.NotificationMetadataHelper.build_facebook_api_error(status_code, response), notify)
    end
  end
  defp parse_access_token({:parse_access_token, response_json, user_id, notify}) do
    case Map.get(response_json, "access_token", "") do
      "" -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :access_token_validation_error, UserManager.Notifications.NotificationMetadataHelper.build_facebook_access_token_validation_error("access_token missing", response_json), notify)#{:access_token_missing, response_json, user_id, notify}
      token ->
        case Map.get(response_json, "expires_in", -1) do
          -1 -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :access_token_validation_error, UserManager.Notifications.NotificationMetadataHelper.build_facebook_access_token_validation_error("expire_time missing", response_json), notify)#{:expire_time_missing, response_json, user_id, notify}
          other -> [{:process_access_token, token, other, user_id, notify}]
        end

    end
  end
end

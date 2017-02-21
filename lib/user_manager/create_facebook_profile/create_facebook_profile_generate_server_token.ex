defmodule UserManager.CreateFacebookProfile.CreateFacebookProfileGenerateServerToken do
  @moduledoc false
  use GenStage
  require Logger
  def start_link(setup) do
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
      {:producer_consumer, [], subscribe_to: [UserManager.CreateFacebookProfile.CreateFacebookProfileValidateCodeToken]}
  end

  @facebook_proxy Application.get_env(:user_manager, :facebook_proxy)

  @doc"""
  facebook server token response

  %HTTPoison.Response{body: "{\"access_token\":\"fdsfsafsafasfsafasfsafsafsafasfsfsafasfsadfsdaffsadfsdafsadfgfdsghfdhfdhfdhfjfghjgfsdgfdfgs\",
  \"token_type\":\"bearer\",\"expires_in\":5181277}", headers: [{"Access-Control-Allow-Origin", "*"},
  {"Pragma", "no-cache"},
  {"Cache-Control", "private, no-cache, no-store, must-revalidate"},
  {"facebook-api-version", "v2.8"}, {"Expires", "Sat, 01 Jan 2000 00:00:00 GMT"},
  {"Content-Type", "application/json; charset=UTF-8"}, {"x-fb-trace-id", "fdsafsadfsad"},
  {"x-fb-rev", "2832002"}, {"Vary", "Accept-Encoding"},
  {"X-FB-Debug", "fdsafdsa/fdsa+s2oipIg26fdsfsdafsajzkpLtQ=="},
   {"Date", "Tue, 14 Feb 2017 09:24:51 GMT"}, {"Transfer-Encoding", "chunked"}, {"Connection", "keep-alive"}], status_code: 200}

"""
  def handle_events(events, from, state) do
    process_events = events |> UserManager.WorkflowProcessing.get_process_events(:process_access_token)
    |> Flow.from_enumerable
    |> Flow.flat_map(fn e -> process_event(e) end)
    |> Flow.flat_map(fn e -> parse_server_token(e) end)
    |> Enum.to_list
    unprocessed_events = UserManager.WorkflowProcessing.get_unprocessed_events(events, :process_access_token)
    {:noreply, process_events ++ unprocessed_events, []}
  end
  defp process_event({:process_access_token, token, expire_time, user_id, notify}) do
    {response, status_code} = @facebook_proxy.get_server_token_from_access_key(token)
    response_json = Poison.Parser.parse!(response)
      case status_code == 200 do
        true -> [{:parse_server_token, token, expire_time, response_json, user_id, notify}]
        false -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :server_token_error, %{"access_token" => token, "access_token_expire_time" => expire_time, "http_status_code" => status_code, "http_response" => response_json}, notify)
                 []#{:server_token_error, token, expire_time, response_json, status_code, user_id, notify}
      end
  end
  defp parse_server_token({:parse_server_token, token, expire_time, response_json, user_id, notify}) do
    case Map.get(response_json, "access_token", "") do
      "" -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :server_token_validation_error, UserManager.Notifications.NotificationMetadataHelper.build_facebook_server_token_validation_error("server token missing", response_json, token, expire_time), notify)
                                        []
      server_token ->
        case Map.get(response_json, "expires_in", -1) do
          -1 ->  UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_facebook_profile, :server_token_validation_error, UserManager.Notifications.NotificationMetadataHelper.build_facebook_server_token_validation_error("server expire time missing", response_json, token, expire_time), notify)
                                        []
          other -> [{:process_server_token, token, expire_time , server_token, other, user_id, notify}]
        end
    end
  end
end

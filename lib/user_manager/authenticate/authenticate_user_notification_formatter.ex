defmodule UserManager.Authenticate.AuthenticateUserNotificationFormatter do
  @moduledoc false
  use GenStage
  alias UserManager.Repo
  require Logger
   def start_link(setup) do
         name = "#{__MODULE__}#{setup}"
         GenStage.start_link(__MODULE__, [], name: __MODULE__)
     end
  def init(stat) do
    {:producer_consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserTokenGenerate]}
  end
  @doc"""
  formatting final notifications for authentication

  ## Examples

    iex>UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:ok, nil, ""}], nil, [])
    {:noreply, [], []}

    iex>UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:user_not_found_error, nil}], nil, [])
    {:noreply, [], []}

    iex>UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:authenticate_failure, nil}], nil, [])
    {:noreply, [], []}

    iex>UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:token_storage_failure, nil}], nil, [])
    {:noreply, [], []}

    iex>UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:token_error, nil, "reasons"}], nil, [])
    {:noreply, [], []}

    iex>{:noreply, response, state} = UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:ok, self(), "someawesometoken"}], nil, [])
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :notify_success
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
    :authentication

    iex>{:noreply, response, state} = UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:user_not_found_error, self()}], nil, [])
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :notify_error
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
    :user_not_found

    iex>{:noreply, response, state} = UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:authenticate_failure, self()}], nil, [])
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :notify_error
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
    :authenticate_failure

    iex>{:noreply, response, state} = UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:token_storage_failure, self()}], nil, [])
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :notify_error
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
    :token_storage_failure

    iex>{:noreply, response, state} = UserManager.Authenticate.AuthenticateUserNotificationFormatter.handle_events([{:token_error, self(), "something"}], nil, [])
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
    :notify_error
    iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 1)
    :authenticate_token_error
"""
  def handle_events(events, from, state) do
    format_events = events
    |> Flow.from_enumerable
    |> Flow.flat_map(fn x -> get_notifications(x) end)
    |> Enum.to_list
    {:noreply, format_events, state}
  end
  defp get_notifications({:ok, nil, _}) do
    []
  end
  defp get_notifications({:user_not_found_error, nil}) do
    []
  end
  defp get_notifications({:authenticate_failure, nil}) do
    []
  end
  defp get_notifications({:token_storage_failure, nil}) do
    []
  end
  defp get_notifications({:token_error, nil, _}) do
    []
  end
  defp get_notifications({:ok, notify, token}) do
    [{:notify_success, :authentication, notify, token}]
  end
  defp get_notifications({:user_not_found_error, notify}) do
    [{:notify_error, :user_not_found, notify}]
  end
  defp get_notifications({:authenticate_failure, notify}) do
    [{:notify_error, :authenticate_failure, notify}]
  end
  defp get_notifications({:token_storage_failure, notify}) do
    [{:notify_error, :token_storage_failure, notify}]
  end
  defp get_notifications({:token_error, notify, reason}) do
    [{:notify_error, :authenticate_token_error, notify, reason}]
  end
end

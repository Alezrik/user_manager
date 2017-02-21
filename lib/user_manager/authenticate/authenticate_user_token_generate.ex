defmodule UserManager.Authenticate.AuthenticateUserTokenGenerate do
  @moduledoc false
   use GenStage
    require Logger
    alias UserManager.User
    alias UserManager.Repo
    import Ecto.Query
    def start_link(setup) do
      GenStage.start_link(__MODULE__, [], [name: __MODULE__])
    end
    def init(state) do
      {:consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserValidation]}
    end
    @doc"""
    generates user tokens

    ## Examples
      iex>name = Faker.Name.first_name <> Faker.Name.last_name
      iex>email = Faker.Internet.email
      iex>{:notify, response} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
      iex>user = Map.fetch!(response.response_parameters, "created_object")
      iex>UserManager.Authenticate.AuthenticateUserTokenGenerate.handle_events([{:authenticate_user, user, :browser, nil}], nil, [])
      {:noreply, [], []}
"""
    def handle_events(events, from, state) do
        process_events = events
        |> Flow.from_enumerable
        |> Flow.map(fn e -> process_event(e) end)
        |> Enum.to_list
        {:noreply, [], state}
    end
    defp group_permissions(user_permission_list) do
      Enum.group_by(user_permission_list, fn x ->
        permission = Repo.preload(x, :permission_group)
        String.to_atom(permission.permission_group.name)
        end, fn x -> String.to_atom(x.name) end)
    end
    defp process_event({:authenticate_user, user, source, notify}) do
      u = Repo.preload(user, :permissions)
      permissions = group_permissions(u.permissions)
      case Guardian.encode_and_sign(u, source, %{"perms" => permissions}) do
        {:ok, jtw, data} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authenticate, :success, %{"authenticate_token" => jtw}, notify)#{:ok, notify, jtw}
        {:error, :token_storage_failure} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authenticate, :token_storage_failure, %{}, notify)#{:token_storage_failure, notify}
        {:error, reason} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authenticate, :token_error, %{"token_error" => reason}, notify)#{:token_error, notify, reason}
      end
    end
end

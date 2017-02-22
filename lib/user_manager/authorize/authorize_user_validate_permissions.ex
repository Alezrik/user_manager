defmodule UserManager.Authorize.AuthorizeUserValidatePermissions do
  @moduledoc false
   use GenStage
        alias UserManager.Schemas.User
        require Logger
         def start_link(setup) do
            name = "#{__MODULE__}#{setup}"
            GenStage.start_link(__MODULE__, [], name: __MODULE__)
        end
        def init(stat) do
          {:consumer, [], subscribe_to: [UserManager.Authorize.AuthorizeUserValidateToken]}
        end
        @doc"""
        validate requested permissions

        ## Examples

          iex>name = Faker.Name.first_name <> Faker.Name.last_name
          iex>email = Faker.Internet.email
          iex>{:notify, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
          iex>{:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
          iex>token = Map.fetch!(response.response_parameters, "authenticate_token")
          iex>msg = {:authorize_token, token, [{:default, :read}], true, nil}
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
          iex>UserManager.Authorize.AuthorizeUserValidatePermissions.handle_events(response, nil, [])
          {:noreply, [], []}

          iex>name = Faker.Name.first_name <> Faker.Name.last_name
          iex>email = Faker.Internet.email
          iex>{:notify, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
          iex>{:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
          iex>token = Map.fetch!(response.response_parameters, "authenticate_token")
          iex>msg = {:authorize_token, token, [{:invalidpermimssiongroup, :read}], true, nil}
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
          iex>UserManager.Authorize.AuthorizeUserValidatePermissions.handle_events(response, nil, [])
          {:noreply, [], []}

          iex>name = Faker.Name.first_name <> Faker.Name.last_name
          iex>email = Faker.Internet.email
          iex>{:notify, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
          iex>{:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
          iex>token = Map.fetch!(response.response_parameters, "authenticate_token")
          iex>msg = {:authorize_token, token, [{:default, :invalidpermission}], true, nil}
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
          iex>UserManager.Authorize.AuthorizeUserValidatePermissions.handle_events(response, nil, [])
          {:noreply, [], []}
"""
        def handle_events(events, from, state) do
          process_events = events
          |> Flow.from_enumerable
          |> Flow.flat_map(fn e -> process_event(e) end)
          |> Enum.to_list
          {:noreply, [], state}
        end
        defp process_event({:validate_permissions, data, permission_list, require_all, notify}) do
          permission_results = Enum.reduce_while(permission_list, {false}, fn {group, per_name}, acc ->
            r = data
            |> Guardian.Permissions.from_claims(group)
            |> Guardian.Permissions.all?([per_name], group)
            check_permission(require_all, r)
           end)
           case permission_results do
             {true} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authorize, :success, %{}, notify)
                        []
             {false} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authorize, :unauthorized, %{}, notify)
                        []
           end
        end
        def check_permission(true, true) do
          {:cont, {true}}
        end
        def check_permission(true, false) do
         {:halt, {false}}
        end
        def check_permission(false, true) do
          {:halt, {true}}
        end
        def check_permission(false, false) do
          {:cont, {false}}
        end
end

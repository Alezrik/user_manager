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
          {:producer_consumer, [], subscribe_to: [UserManager.Authorize.AuthorizeUserValidateToken]}
        end
        @doc"""
        validate requested permissions

        ## Examples

          iex>name = Faker.Name.first_name <> Faker.Name.last_name
          iex>email = Faker.Internet.email
          iex>{:ok, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
          iex>{:ok, token} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
          iex>msg = {:authorize_token, token, [{:default, :read}], true, nil}
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidatePermissions.handle_events(response, nil, [])
          iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
          :ok

          iex>name = Faker.Name.first_name <> Faker.Name.last_name
          iex>email = Faker.Internet.email
          iex>{:ok, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
          iex>{:ok, token} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
          iex>msg = {:authorize_token, token, [{:invalidpermimssiongroup, :read}], true, nil}
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidatePermissions.handle_events(response, nil, [])
          iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
          :error

          iex>name = Faker.Name.first_name <> Faker.Name.last_name
          iex>email = Faker.Internet.email
          iex>{:ok, _user} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
          iex>{:ok, token} = UserManager.UserManagerApi.authenticate_user(name, "secretpassword", :browser)
          iex>msg = {:authorize_token, token, [{:default, :invalidpermission}], true, nil}
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidateToken.handle_events([msg], nil, [])
          iex>{:noreply, response, state} = UserManager.Authorize.AuthorizeUserValidatePermissions.handle_events(response, nil, [])
          iex>Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
          :error

"""
        def handle_events(events, from, state) do
          process_events = events |> UserManager.WorkflowProcessing.get_process_events(:validate_permissions)
          |> Flow.from_enumerable
          |> Flow.map(fn e -> process_event(e) end)
          |> Enum.to_list
          un_processed_events =  UserManager.WorkflowProcessing.get_unprocessed_events(events, :validate_permissions)
          {:noreply, process_events ++ un_processed_events, state}
        end
        defp process_event({:validate_permissions, data, permission_list, require_all, notify}) do
          permission_results = Enum.reduce_while(permission_list, {false}, fn {group, per_name}, acc ->
            r = data
            |> Guardian.Permissions.from_claims(group)
            |> Guardian.Permissions.all?([per_name], group)
            check_permission(require_all, r)
           end)
           case permission_results do
             {true} -> {:ok, notify}
             {false} -> {:error, :unauthorized, notify}
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

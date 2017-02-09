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
        def handle_events(events, from, state) do
          process_events = events
          |> Enum.filter(fn  e ->
            case e do
              {:validate_permissions, data, permission_list, require_all, notify} -> true
              other -> false
            end
          end)
          |> Flow.from_enumerable
          |> Flow.map(fn {:validate_permissions, data, permission_list, require_all, notify} ->
            permission_results = Enum.reduce_while(permission_list, false, fn {group, per_name}, acc ->
              r = data
              |> Guardian.Permissions.from_claims(group)
              |> Guardian.Permissions.all?([per_name], group)
               case require_all do
                 true ->
                  case r do
                    true -> {:cont, {true}}
                    false -> {:halt, {false}}
                  end
                 false ->
                  case r do
                    true -> {:halt, {true}}
                    false -> {:cont, {false}}
                  end
               end
             end)
             case permission_results do
               {true} -> {:ok, notify}
               {false} -> {:error, :unauthorized, notify}
             end

          end)
          |> Enum.to_list

          un_processed_events = events
          |> Enum.filter(fn  e ->
            case e do
              {:validate_permissions, data, permission_list, require_all, notify} -> false
              other -> true
            end
          end)
          {:noreply, process_events ++ un_processed_events, state}
        end
end
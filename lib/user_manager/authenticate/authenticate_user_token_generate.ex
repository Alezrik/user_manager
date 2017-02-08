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
      {:producer_consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserValidation]}
    end
    def handle_events(events, from, state) do
        process_events = events
        |> Enum.filter(fn e -> case e do
            {:authenticate_user, user, source, notify} -> true
            other -> false
          end
        end)
        |> Flow.from_enumerable
        |> Flow.map(fn {:authenticate_user, user, source, notify} ->
          u = user |> Repo.preload(:permissions)
          permissions = group_permissions(u.permissions)
          case Guardian.encode_and_sign(user, source, %{"perms" => permissions}) do
            {:ok, jtw, data} -> {:ok, notify, jtw}
            {:error, :token_storage_failure} -> {:token_storage_failure, notify}
            {:error, reason} -> {:token_error, notify, reason}
          end
         end)
        |> Enum.to_list
        un_process_events = events
        |> Enum.filter(fn e -> case e do
            {:authenticate_user, user, source, notify} -> false
            other -> true
          end
        end)
        {:noreply, process_events ++ un_process_events, state}
    end
    @spec group_permissions(List.t) :: Map.t
    defp group_permissions(user_permission_list) do
      Enum.group_by(user_permission_list, fn x ->
        permission = x |> Repo.preload(:permission_group)
        String.to_atom(permission.permission_group.name)
        end, fn x -> String.to_atom(x.name) end)
    end
end
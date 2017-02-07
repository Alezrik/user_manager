defmodule UserManager.UserProfile.CreateUserPermissions do
  @moduledoc false
  use GenStage
  alias UserManager.Permission
  alias UserManager.PermissionGroup
  alias UserManager.Repo
  import Ecto.Query
  import Ecto.Changeset
  require Logger
   def start_link(setup) do
     name = "#{__MODULE__}#{setup}"
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
#    default_create_permissions = Map.to_list(Application.get_env(:user_manager, :new_user_default_permissions))
#    Logger.debug "!!!default_create_permissions: #{inspect default_create_permissions}"
#    create_permissions_state = Enum.flat_map(default_create_permissions, fn p -> get_permission_from_state(p) end)
    {:producer_consumer, [], subscribe_to: [UserManager.UserProfile.CreateUserRepoInsert]}
  end
  def get_permission_from_state({group, per_list}) do
    case PermissionGroup |> where(name: ^Atom.to_string(group)) |> Repo.one do
      nil -> []
      gr ->
        group = gr |> Repo.preload(:permissions)
        Enum.flat_map(per_list, fn l -> Enum.filter(group.permissions, fn p -> p.name == Atom.to_string(l) end) end)
    end
  end
  def handle_events(events, from, _state) do
    default_create_permissions = Map.to_list(Application.get_env(:user_manager, :new_user_default_permissions))
    create_permissions_state = Enum.flat_map(default_create_permissions, fn p -> get_permission_from_state(p) end)
    process_events = Enum.filter(events, fn e ->
      case e do
        {:insert_permissions, user, notify} -> true
        other -> false
      end
     end)
     |> Flow.from_enumerable
     |> Flow.map(fn e ->
        {:insert_permissions, user, notify} = e
        event_permissions_inserts = Stream.map(create_permissions_state, fn p ->
          permission = p |> Repo.preload(:users)
          user_list = [user | permission.users]
           changeset = permission |> Permission.changeset(%{}) |> put_assoc(:users, user_list)
           case Repo.update(changeset) do
            {:ok, update_permission} -> {:ok, update_permission}
            {:error, changeset} -> {:update_error, changeset}
           end
         end)
         {e, event_permissions_inserts}
      end)
      |> Flow.map(fn e ->
        {{:insert_permissions, user, notify}, event_permissions_inserts} = e
        Enum.reduce_while(event_permissions_inserts, {:notify_success, notify, user}, fn p, acc ->
          case p do
            {:ok, _} -> {:cont, acc}
            {:update_error, changeset} -> {:halt, {:notify_error, notify, :update_permission_error, changeset.errors}}
          end
         end)
       end)
      |> Enum.to_list
      unprocessed_events = Enum.filter(events, fn e ->
       case e do
         {:insert_permissions, user, notify} -> false
         other -> true
       end
      end)
      |> Enum.map(fn e ->
        case e do
          {:validation_error, errors, notify} -> {:notify_error, notify, :validation_error, errors}
          {:insert_error, errors, notify} -> {:notify_error, notify, :insert_error, errors}
        end
       end)

    {:noreply, process_events ++ unprocessed_events, _state}
  end
end
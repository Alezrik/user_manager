defmodule UserManager.CreateUser.CreateUserPermissions do
  @moduledoc false
  use GenStage
  alias UserManager.Schemas.Permission
  alias UserManager.Schemas.PermissionGroup
  alias UserManager.Repo
  import Ecto.Query
  import Ecto.Changeset
  require Logger
   def start_link(setup) do
     name = "#{__MODULE__}#{setup}"
      GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(stat) do
    {:producer_consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserRepoInsert]}
  end
  @doc"""

  responsible for attaching default permissions to users

  ##Examples

    iex>userchangeset =UserManager.Schemas.UserSchema.changeset( %UserManager.Schemas.UserSchema{}, %{})
    iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserRepoInsert.handle_events([{:insert_user, userchangeset, nil}], self(), [])
    iex>user = Enum.at(Tuple.to_list(Enum.at(response,0)),1)
    iex>{:noreply, response, state} = UserManager.CreateUser.CreateUserPermissions.handle_events([{:insert_permissions, user, nil}], self(), [])
    iex>Enum.at(Tuple.to_list(Enum.at(response,0)),0)
    :ok

"""
  def handle_events(events, from, state) do
    process_events =  events |> UserManager.WorkflowProcessing.get_process_events(:insert_permissions)
     |> Flow.from_enumerable
     |> Flow.map(fn e -> process_insert_permissions(e) end)
     |> Flow.map(fn e -> process_insert_results(e) end)
     |> Enum.to_list
     unprocessed_events =  UserManager.WorkflowProcessing.get_unprocessed_events(events, :insert_permissions)
     {:noreply, process_events ++ unprocessed_events, state}
  end
  defp process_insert_results({{:insert_permissions, user, notify}, event_permissions_inserts}) do
    compile_update_result(event_permissions_inserts, user, notify)
  end
  defp process_insert_permissions({:insert_permissions, user, notify}) do
    create_permissions = GenServer.call(UserManager.PermissionRepo, {:get_default_user_create_permission_ids})
    Logger.debug "create permission ids: #{inspect create_permissions}"
    event_permissions_inserts = Stream.map(create_permissions, fn p_id ->
      permission = Permission
      |> where(id: ^p_id)
      |> Repo.one!
      |> Repo.preload(:users)
      user_list = [user | permission.users]
      changeset = permission |> Permission.changeset(%{}) |> put_assoc(:users, user_list)
      update_repo(changeset)
     end)
     {{:insert_permissions, user, notify}, event_permissions_inserts}
  end
  defp update_repo(changeset) do
    case Repo.update(changeset) do
      {:ok, update_permission} -> {:ok, update_permission}
      {:error, changeset} -> {:update_error, changeset}
     end
  end
  defp compile_update_result(event_permissions_inserts, user, notify) do
    Enum.reduce_while(event_permissions_inserts, {:ok, notify, user}, fn p, acc ->
      case p do
        {:ok, _} -> {:cont, acc}
        {:update_error, changeset} -> {:halt, {:update_permission_error, notify, changeset.errors}}
      end
     end)
  end
end

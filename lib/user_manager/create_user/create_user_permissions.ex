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
    {:consumer, [], subscribe_to: [UserManager.CreateUser.CreateUserRepoInsert]}
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
     process_events = events
     |> Flow.from_enumerable
     |> Flow.map(fn e -> process_insert_permissions(e) end)
     |> Flow.flat_map(fn e -> process_insert_results(e) end)
     |> Enum.to_list
     {:noreply, process_events, state}
  end
  defp process_insert_results({{:insert_permissions, user, notify}, event_permissions_inserts}) do
    compile_update_result(event_permissions_inserts, user, notify)
  end
  defp process_insert_permissions({:insert_permissions, user, notify}) do
    create_permissions = GenServer.call(UserManager.PermissionRepo, {:get_default_user_create_permission_ids})
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
    case Enum.reduce_while(event_permissions_inserts, {:ok, notify, user}, fn p, acc ->
       continue_reduce(p, acc, notify)
     end) do
       {:ok, notify, user} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_user, :success,
                                                                UserManager.Notifications.NotificationMetadataHelper.build_create_user_success(user),
                                                                notify)
                                                                []#[{:ok, notify, user}]
       {:update_permission_error, notify, changeset} -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_user, :update_error,
                                                        UserManager.Notifications.NotificationMetadataHelper.build_changeset_validation_error(:user, changeset),
                                                        notify)
                                                        []
     end
  end
  defp continue_reduce(p, acc, notify) do
    case p do
      {:ok, _} -> {:cont, acc}
      {:update_error, changeset} -> {:halt, {:update_permission_error, notify, changeset}}
    end
  end
end

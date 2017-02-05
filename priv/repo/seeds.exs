alias UserManager.PermissionGroup
alias UserManager.Permission
alias UserManager.Repo
import Ecto.Changeset
import Ecto.Query


permissions_list = Map.to_list(Application.get_env(:guardian, Guardian)[:permissions] )

Enum.each(permissions_list, fn p ->
   {permission_group, p_list} = p
   group = PermissionGroup.changeset(%PermissionGroup{}, %{"name" =>Atom.to_string(permission_group)})
   {:ok, group_insert} = Repo.insert(group)
   Enum.each(p_list, fn  per ->
    permission_to_save = Permission.changeset(%Permission{}, %{"name"=>Atom.to_string(per)}) |> put_assoc(:permission_group, group_insert)
    {:ok, _res} = Repo.insert(permission_to_save)
   end)
 end)




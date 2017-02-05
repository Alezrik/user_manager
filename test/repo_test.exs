defmodule RepoTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.User
    alias UserManager.Permission
    alias UserManager.PermissionGroup
    import Ecto.Changeset
    test "create user with a permission from valid changeset" do
      permission_group = PermissionGroup.changeset(%PermissionGroup{}, %{"name" => "test_group1"})
      assert permission_group.valid?
      {:ok, permission_group_serialized} = Repo.insert(permission_group)
      permission_group_serialized = permission_group_serialized |> Repo.preload(:permissions)
      permission = Permission.changeset(%Permission{}, %{"name" => "test_permission1"})
      |> put_assoc(:permission_group, permission_group_serialized)
      assert permission.valid?
      {:ok, permission_serialized} = Repo.insert(permission)
      user = User.changeset(%User{}, %{"name" => Faker.Name.first_name, "password" => <<"somelegalpassword">>}) |> put_assoc(:permissions, [permission_serialized])
      assert user.valid?, user.errors
      {:ok, insert} = Repo.insert(user)
    end

    test "create user with a permission from valid changesets" do
      permission_group = PermissionGroup.changeset(%PermissionGroup{}, %{"name" => "test_group2"})
      assert permission_group.valid?
      {:ok, permission_group_serialized} = Repo.insert(permission_group)
      permission = Permission.changeset(%Permission{}, %{"name" => "test_permission2"})
      |> put_assoc(:permission_group, permission_group)
      assert permission.valid?
      user = User.changeset(%User{}, %{"name" => Faker.Name.first_name, "password" => <<"somelegalpassword">>}) |> cast_assoc(:permissions, [permission])
      assert user.valid?, user.errors
      {:ok, insert} = Repo.insert(user)
    end
end
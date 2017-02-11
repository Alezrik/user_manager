defmodule RepoTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.Schemas.User
    alias UserManager.Schemas.Permission
    alias UserManager.Schemas.PermissionGroup
    alias UserManager.Schemas.UserProfile
    import Ecto.Changeset
    test "create user with a permission from valid changeset" do
      permission_group = PermissionGroup.changeset(%PermissionGroup{}, %{"name" => "test_group1"})
      assert permission_group.valid?
      {:ok, permission_group_serialized} = Repo.insert(permission_group)
      permission_group_serialized =  Repo.preload(permission_group_serialized, :permissions)
      permission = put_assoc(Permission.changeset(%Permission{}, %{"name" => "test_permission1"}), :permission_group, permission_group_serialized)
      assert permission.valid?
      {:ok, permission_serialized} = Repo.insert(permission)
      user_profile = UserProfile.changeset(%UserProfile{}, %{"name" => Faker.Name.first_name, "password" => <<"somelegalpassword">>, "email" => Faker.Internet.email})
      user = User.changeset(%User{}, %{}) |> put_assoc(:permissions, [permission_serialized]) |> put_assoc(:user_profile, user_profile)
      assert user.valid?, user.errors
      {:ok, insert} = Repo.insert(user)
    end

    test "create user with a permission from valid changesets" do
      permission_group = PermissionGroup.changeset(%PermissionGroup{}, %{"name" => "test_group2"})
      assert permission_group.valid?
      {:ok, permission_group_serialized} = Repo.insert(permission_group)
      permission = Permission.changeset(%Permission{}, %{"name" => "test_permission2"})
      assert permission.valid?
      user_profile = UserProfile.changeset(%UserProfile{}, %{"name" => Faker.Name.first_name, "password" => <<"somelegalpassword">>, "email" => Faker.Internet.email})
      user = User.changeset(%User{}, %{}) |> put_assoc(:permissions, [permission]) |> put_assoc(:user_profile, user_profile)
      assert user.valid?, user.errors
      {:ok, insert} = Repo.insert(user)
    end
end

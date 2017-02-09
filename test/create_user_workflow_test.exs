defmodule CreateUserWorkflowTest do
  use ExUnit.Case
  alias UserManager.Repo
  alias UserManager.User
  alias UserManager.Permission
  alias UserManager.PermissionGroup
  import Ecto.Changeset
  require Logger
  test "create user workflow" do
     {:ok, user} = UserManager.UserManagerApi.create_user(Faker.Name.first_name<>Faker.Name.last_name, "fdsafdsfasfdsa")
     {:error, :create_user_validation_error, error_list} =  UserManager.UserManagerApi.create_user(Faker.Name.first_name<>Faker.Name.last_name, "fdsa")
   end

end
defmodule CreateUserWorkflowTest do
  use ExUnit.Case
  alias UserManager.Repo
  alias UserManager.Schemas.User
  alias UserManager.Schemas.Permission
  alias UserManager.Schemas.PermissionGroup
  import Ecto.Changeset
  require Logger
  test "create user workflow" do
     {:ok, user} = UserManager.UserManagerApi.create_user(Faker.Name.first_name<>Faker.Name.last_name, "fdsafdsfasfdsa", Faker.Internet.email)
     {:error, :create_user_validation_error, error_list} =  UserManager.UserManagerApi.create_user(Faker.Name.first_name<>Faker.Name.last_name, "fdsa", Faker.Internet.email)
   end

end
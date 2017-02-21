defmodule CreateUserWorkflowTest do
  use ExUnit.Case
  alias UserManager.Repo
  alias UserManager.Schemas.User
  alias UserManager.Schemas.Permission
  alias UserManager.Schemas.PermissionGroup
  import Ecto.Changeset
  require Logger
  test "create user workflow" do
     {:notify, response} = UserManager.UserManagerApi.create_user(Faker.Name.first_name <> Faker.Name.last_name, "fdsafdsfasfdsa", Faker.Internet.email)
     assert response.notification_type == :success
     assert Map.fetch!(response.response_parameters, "created_type") == :user_schema
     user = Map.fetch!(response.response_parameters, "created_object")
     assert user.id > 0
   end
   test "create invalid user workflow" do
     {:notify, error_response} =  UserManager.UserManagerApi.create_user(Faker.Name.first_name <> Faker.Name.last_name, "fdsa", Faker.Internet.email)
     assert error_response.notification_type == :validation_error
   end
end

defmodule UserCrudApiTest do
  use ExUnit.Case

  test "delete a user" do
    name = Faker.Name.first_name <> Faker.Name.last_name
    {:notify, response} = UserManager.UserManagerApi.create_user(name, "fdsafdsa", Faker.Internet.email)
    user = Map.fetch!(response.response_parameters, "created_object")
    :ok = UserManager.UserManagerApi.delete_user(user.id)
    {:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "fdsafdsa")
    assert response.notification_type == :user_not_found

  end
  test "update a user" do
    name = Faker.Name.first_name <> Faker.Name.last_name
    {:notify, response} = UserManager.UserManagerApi.create_user(name, "fdsafdsa", Faker.Internet.email)
    user = Map.fetch!(response.response_parameters, "created_object")
    {:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "fdsafdsa")
    assert response.notification_type == :success
    {:ok, u} = UserManager.UserManagerApi.update_user_password(user.id, "abcdefghijkl")
    {:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "fdsafdsa")
    assert response.notification_type == :authenticate_failure
    {:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "abcdefghijkl")
    assert response.notification_type == :success
  end
end

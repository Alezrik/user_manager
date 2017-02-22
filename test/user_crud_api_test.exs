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
end

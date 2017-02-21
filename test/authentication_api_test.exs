defmodule AuthenticationApiTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.Schemas.UserSchema
    require Logger
    setup_all do
      {:notify, _} = UserManager.UserManagerApi.create_user("testuser1", "testpassword1", Faker.Internet.email)
      :ok
    end
    test "authenticate and identify user" do
      {:notify, _} = UserManager.UserManagerApi.authenticate_user("testuser1", "testpassword1")
    end
    test "identify user" do
      {:notify, response} = UserManager.UserManagerApi.authenticate_user("testuser1", "testpassword1")
      token = Map.fetch!(response.response_parameters, "authenticate_token")
      {:notify, response} = UserManager.UserManagerApi.identify_user(token)
      user = Map.fetch!(response.response_parameters, "user")
      assert user != nil
      assert user.id > 0
      user =  Repo.preload(user, :user_profile)
      assert user.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("name") == "testuser1"
      assert Comeonin.Bcrypt.checkpw("testpassword1", user.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("secretkey"))
    end
    test "invalid authenticate" do
      {:notify, response} = UserManager.UserManagerApi.authenticate_user("testuser1", "")
      assert response.notification_type == :authenticate_failure
      {:notify, response} = UserManager.UserManagerApi.authenticate_user("", "testpassword1")
      assert response.notification_type == :user_not_found
      {:notify, response} = UserManager.UserManagerApi.authenticate_user("fdsafdsa", "fdsfdas")
      assert response.notification_type == :user_not_found
    end
    test "invalid identify" do
      {:notify, response} = UserManager.UserManagerApi.identify_user("fjkdsfkljasfkjlas")
      assert response.notification_type == :token_decode_error
    end
    test "valid token not saved identify" do
         token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjQiLCJleHAiOjE0ODkzMDMyMTksImlhdCI6MTQ4NjcxMTIxOSwiaXNzIjoiU29tZW9uZSIsImp0aSI6Ijg0NGUwY2EzLWM4ZWUtNDQ3Mi1iMzYxLWVhODdjNGUzYjU3NCIsInBlbSI6eyJkZWZhdWx0IjoxfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYnJvd3NlciJ9.nA3-dkFNqTW1GYO8x1v9zTQoUk6ddyK2FqgZPZk9k6lO_iIOQx6We35ItLEeRAZO_5lv9JR4WWizQ7J7p8HRcA"
        {:notify, response} = UserManager.UserManagerApi.identify_user(token)
        response.notification_type == :token_not_found
    end
    test "authenticate requires permission" do
      import Ecto.Changeset
      {:notify, response} = UserManager.UserManagerApi.create_user("testuser_permission", "testpassword1", Faker.Internet.email)
      metadata = response.response_parameters
      user = Map.fetch!(metadata, "created_object")
      u = user |> Repo.preload(:permissions) |> Repo.preload(:user_profile)
      permissions = u.permissions |> Enum.filter(fn p -> p.name != "credential" end) |> Enum.map(fn p -> p |> Repo.preload(:users) |> Repo.preload(:permission_group) end)
      changeset = u |> UserSchema.changeset(%{}) |> put_assoc(:permissions, permissions)
      Repo.update(changeset)
      {:notify, response} = UserManager.UserManagerApi.authenticate_user("testuser_permission", "testpassword1")
      assert response.notification_type == :authorization_failure
    end
end

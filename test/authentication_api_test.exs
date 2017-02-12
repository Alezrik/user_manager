defmodule AuthenticationApiTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.Schemas.UserSchema
    require Logger
    setup_all do
      {:ok, user} = UserManager.UserManagerApi.create_user("testuser1", "testpassword1", Faker.Internet.email)
      :ok
    end
    test "authenticate and identify user" do
      {:ok, _} = UserManager.UserManagerApi.authenticate_user("testuser1", "testpassword1")
    end
    test "identify user" do
      {:ok, token} = UserManager.UserManagerApi.authenticate_user("testuser1", "testpassword1")
      {:ok, user} = UserManager.UserManagerApi.identify_user(token)
      assert user != nil
      assert user.id > 0
      user =  Repo.preload(user, :user_profile)
      assert user.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("name") == "testuser1"
      assert Comeonin.Bcrypt.checkpw("testpassword1", user.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("password"))
    end
    test "invalid authenticate" do
      {:error, :authenticate_failure} = UserManager.UserManagerApi.authenticate_user("testuser1", "")
      {:error, :user_not_found} = UserManager.UserManagerApi.authenticate_user("", "testpassword1")
      {:error, :user_not_found} = UserManager.UserManagerApi.authenticate_user("fdsafdsa", "fdsfdas")
    end
    test "invalid identify" do
      {:error, :token_decode_error, _} = UserManager.UserManagerApi.identify_user("fjkdsfkljasfkjlas")
    end
    test "valid token not saved identify" do
         token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjQiLCJleHAiOjE0ODkzMDMyMTksImlhdCI6MTQ4NjcxMTIxOSwiaXNzIjoiU29tZW9uZSIsImp0aSI6Ijg0NGUwY2EzLWM4ZWUtNDQ3Mi1iMzYxLWVhODdjNGUzYjU3NCIsInBlbSI6eyJkZWZhdWx0IjoxfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYnJvd3NlciJ9.nA3-dkFNqTW1GYO8x1v9zTQoUk6ddyK2FqgZPZk9k6lO_iIOQx6We35ItLEeRAZO_5lv9JR4WWizQ7J7p8HRcA"
        {:error, :token_not_found} = UserManager.UserManagerApi.identify_user(token)
    end
    test "authenticate requires permission" do
      import Ecto.Changeset
      {:ok, user} = UserManager.UserManagerApi.create_user("testuser_permission", "testpassword1", Faker.Internet.email)
      u = user |> Repo.preload(:permissions) |> Repo.preload(:user_profile)
      permissions = u.permissions |> Enum.filter(fn p -> p.name != "credential" end) |> Enum.map(fn p -> p |> Repo.preload(:users) |> Repo.preload(:permission_group) end)
      changeset = u |> UserSchema.changeset(%{}) |> put_assoc(:permissions, permissions)
      Repo.update(changeset)
      {:error, :authorization_failure} = UserManager.UserManagerApi.authenticate_user("testuser_permission", "testpassword1")
    end
end

defmodule AuthenticationApiTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.Schemas.User
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
      user = user |> Repo.preload(:user_profile)
      assert user.user_profile.name == "testuser1"
      assert Comeonin.Bcrypt.checkpw("testpassword1", user.user_profile.password)
    end
    test "invalid authenticate" do
      {:error, :authenticate_failure} = UserManager.UserManagerApi.authenticate_user("testuser1", "")
      {:error, :user_not_found} = UserManager.UserManagerApi.authenticate_user("", "testpassword1")
      {:error, :user_not_found} = UserManager.UserManagerApi.authenticate_user("fdsafdsa", "fdsfdas")
    end
    test "invalid identify" do
      {:error, :token_decode_error, _} = UserManager.UserManagerApi.identify_user("fjkdsfkljasfkjlas")
    end
end
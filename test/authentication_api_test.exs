defmodule AuthenticationApiTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.User
    require Logger
    setup_all do
      user = User.changeset(%User{}, %{"name" => "testuser1", "password" => "testpassword1"})
      user = Repo.insert(user)
      case user do
        nil -> :error
        notnil -> :ok
      end
    end
    test "authenticate and identify user" do
      {:ok, _} = UserManager.UserManagerApi.authenticate_user("testuser1", "testpassword1")
    end
    test "identify user" do
      {:ok, token} = UserManager.UserManagerApi.authenticate_user("testuser1", "testpassword1")
      {:ok, user} = UserManager.UserManagerApi.identify_user(token)

      assert user != nil
      assert user.id > 0
      assert user.name == "testuser1"
      assert user.password == "testpassword1"
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
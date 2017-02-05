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

      {:ok, token} = UserManager.AuthenticationApi.authenticate_user("testuser1", "testpassword1")
      {:ok, user} = UserManager.AuthenticationApi.identify_user(token)

      assert user != nil
      assert user.id > 0
      assert user.name == "testuser1"
      assert user.password == "testpassword1"

    end
    test "invalid authenticate" do
      {:error} = UserManager.AuthenticationApi.authenticate_user("testuser1", "")
      {:error} = UserManager.AuthenticationApi.authenticate_user("", "testpassword1")
      {:error} = UserManager.AuthenticationApi.authenticate_user("fdsafdsa", "fdsfdas")
    end
    test "invalid identify" do
      {:error} = UserManager.AuthenticationApi.identify_user("fjkdsfkljasfkjlas")
    end
end
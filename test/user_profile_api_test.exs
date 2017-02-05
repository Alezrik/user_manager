defmodule UserProfileApiTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.User
    alias UserManager.UserProfileApi
   test "create user" do

        {:ok, insert_user} = UserProfileApi.create_user(Faker.Name.first_name, "someawesomepassword")
        {:error, error_list} = UserProfileApi.create_user(Faker.Name.first_name, "")
        {:error, error_list} = UserProfileApi.create_user("", "someawesomepassword")

   end
end
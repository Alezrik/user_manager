defmodule AuthorizeApiTest do
  use ExUnit.Case
      alias UserManager.Repo
      alias UserManager.Schemas.User
      require Logger
      setup_all context do
        name = Faker.Name.first_name<>Faker.Name.last_name<>"007"
        {:ok, user} = UserManager.UserManagerApi.create_user(name, "testpassword1", Faker.Internet.email)
        {:ok, token} = UserManager.UserManagerApi.authenticate_user(name, "testpassword1")
        [token: token]
      end
      test "authorize valid permission", context do
        token = context[:token]
        {:ok} = UserManager.UserManagerApi.authorize_claims(token, [{"default", :read}], true)
      end
      test "refuse invalid permission group", context do
        token = context[:token]
        {:error, :unauthorized} = UserManager.UserManagerApi.authorize_claims(token, [{"invalidnotreal", :read}], true)
      end
      test "refuse invalid permission", context do
        token = context[:token]
        {:error, :unauthorized} = UserManager.UserManagerApi.authorize_claims(token, [{"default", :invalidnotreal}], true)
      end
      test "invalid token" do
        {:error, :token_decode_error} = UserManager.UserManagerApi.authorize_claims("fdsklfsakf", [{"default", :read}], true)
      end
      test "valid token, not saved" do
        token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjQiLCJleHAiOjE0ODkzMDMyMTksImlhdCI6MTQ4NjcxMTIxOSwiaXNzIjoiU29tZW9uZSIsImp0aSI6Ijg0NGUwY2EzLWM4ZWUtNDQ3Mi1iMzYxLWVhODdjNGUzYjU3NCIsInBlbSI6eyJkZWZhdWx0IjoxfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYnJvd3NlciJ9.nA3-dkFNqTW1GYO8x1v9zTQoUk6ddyK2FqgZPZk9k6lO_iIOQx6We35ItLEeRAZO_5lv9JR4WWizQ7J7p8HRcA"
        {:error, :token_not_found} = UserManager.UserManagerApi.authorize_claims(token, [{"default", :read}], true)
      end
end
defmodule AuthorizeApiTest do
  use ExUnit.Case
      alias UserManager.Repo
      alias UserManager.Schemas.User
      require Logger
      setup_all context do
        name = Faker.Name.first_name <> Faker.Name.last_name <> "007"
        {:notify, _} = UserManager.UserManagerApi.create_user(name, "testpassword1", Faker.Internet.email)
        {:notify, response} = UserManager.UserManagerApi.authenticate_user(name, "testpassword1")
        [token: Map.fetch!(response.response_parameters, "authenticate_token")]
      end
      test "authorize valid permission", context do
        token = context[:token]
        {:notify, response} = UserManager.UserManagerApi.authorize_claims(token, [{"default", :read}], true)
        assert response.notification_type == :success
      end
      test "refuse invalid permission group", context do
        token = context[:token]
        {:notify, response} = UserManager.UserManagerApi.authorize_claims(token, [{"invalidnotreal", :read}], true)
        assert response.notification_type == :unauthorized
      end
      test "refuse invalid permission", context do
        token = context[:token]
        {:notify, response} = UserManager.UserManagerApi.authorize_claims(token, [{"default", :invalidnotreal}], true)
        assert response.notification_type == :unauthorized
      end
      test "invalid token" do
        {:notify, response} = UserManager.UserManagerApi.authorize_claims("fdsklfsakf", [{"default", :read}], true)
        assert response.notification_type == :token_decode_error
      end
      test "valid token, not saved" do
        token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjQiLCJleHAiOjE0ODkzMDMyMTksImlhdCI6MTQ4NjcxMTIxOSwiaXNzIjoiU29tZW9uZSIsImp0aSI6Ijg0NGUwY2EzLWM4ZWUtNDQ3Mi1iMzYxLWVhODdjNGUzYjU3NCIsInBlbSI6eyJkZWZhdWx0IjoxfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYnJvd3NlciJ9.nA3-dkFNqTW1GYO8x1v9zTQoUk6ddyK2FqgZPZk9k6lO_iIOQx6We35ItLEeRAZO_5lv9JR4WWizQ7J7p8HRcA"
        {:notify, response} = UserManager.UserManagerApi.authorize_claims(token, [{"default", :read}], true)
        assert response.notification_type == :token_not_found
      end
end

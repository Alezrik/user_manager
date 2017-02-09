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
end
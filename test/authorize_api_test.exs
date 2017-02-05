defmodule AuthorizeApiTest do
  use ExUnit.Case
      alias UserManager.Repo
      alias UserManager.User
      require Logger
      setup_all context do
        name = Faker.Name.first_name
        {:ok, user} = UserManager.UserProfileApi.create_user(name, "testpassword1")
        {:ok, token} = UserManager.AuthenticationApi.authenticate_user(name, "testpassword1")
        [token: token]
      end
      test "authorize valid permission", context do
        token = context[:token]
        {:ok} = UserManager.AuthorizationApi.authorize_all_claims(token, [{"default", :read}])
      end
      test "refuse invalid permission group", context do
        token = context[:token]
        {:error} = UserManager.AuthorizationApi.authorize_all_claims(token, [{"invalidnotreal", :read}])
      end
      test "refuse invalid permission", context do
        token = context[:token]
        {:error} = UserManager.AuthorizationApi.authorize_all_claims(token, [{"default", :invalid_not_real}])
      end
end
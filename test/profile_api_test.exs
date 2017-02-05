defmodule ProfileApiTest do
  use ExUnit.Case
    alias UserManager.Repo
    alias UserManager.User
    alias UserManager.Permission
    alias UserManager.PermissionGroup
    import Ecto.Changeset
    import ExProf.Macro
    @tag external: true
    test "profile create user" do
      name = Faker.Name.first_name<>Faker.Name.last_name
      :fprof.apply(fn ->
        UserManager.UserProfileApi.create_user(name, "fsdkalfasklf")
      end, [])
      :fprof.profile()
      :fprof.analyse(callers: true,
                     sort: :own,
                     totals: true,
                     details: true)
    end

    @tag external: true
    test "profile authenticate" do
       name = Faker.Name.first_name<>Faker.Name.last_name
       UserManager.UserProfileApi.create_user(name, "fsdkalfasklf")
       :fprof.apply(fn ->
          UserManager.AuthenticationApi.authenticate_user(name, "fsdkalfasklf")
        end, [])
        :fprof.profile()
        :fprof.analyse(callers: true,
                       sort: :own,
                       totals: true,
                       details: true)
    end
    @tag external: true
    test "profile identify" do
         name = Faker.Name.first_name<>Faker.Name.last_name
         UserManager.UserProfileApi.create_user(name, "fsdkalfasklf")
         {:ok, token} = UserManager.AuthenticationApi.authenticate_user(name, "fsdkalfasklf")
         :fprof.apply(fn ->
            UserManager.AuthenticationApi.identify_user(token)
          end, [])
          :fprof.profile()
          :fprof.analyse(callers: true,
                         sort: :own,
                         totals: true,
                         details: true)
      end
end
defmodule ProfileCreateUserPermissions do
  use ExUnit.Case
  import ExProf.Macro
  @tag :profile
  test "profile create user permissions" do
          userchangeset = UserManager.Schemas.UserSchema.changeset(%UserManager.Schemas.UserSchema{}, %{})
          {:noreply, response, state} = UserManager.CreateUser.CreateUserRepoInsert.handle_events([{:insert_user, userchangeset, nil}], nil, [])
          user = Enum.at(Tuple.to_list(Enum.at(response,0)),1)
    profile do
      {:noreply, response, state} = UserManager.CreateUser.CreateUserPermissions.handle_events([{:insert_permissions, user, nil}], nil, [])
    end
   # do_analyze
  end

end

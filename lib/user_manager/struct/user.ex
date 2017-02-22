defmodule UserManager.Struct.User do
  alias UserManager.Schemas.UserSchema
  alias UserManager.Repo
  import Ecto.Query
  require Logger
  @moduledoc false
  defstruct user_schema_id: -1, user_profile_id: -1, authenticate_providers: [], permissions: %{}

  def load_user(user_schema_id) do
    basic_user_record = UserSchema
    |> where(id: ^user_schema_id)
    |> Repo.one!
    |> Repo.preload(:user_profile)
    |> Repo.preload(:permissions)
    user_profile_id = case basic_user_record.user_profile == nil do
      true -> -1
      false -> basic_user_record.user_profile.id
    end
    permissions = Enum.group_by(basic_user_record.permissions, fn p ->
       per = Repo.preload(p, :permission_group)
       case per.permission_group == nil do
         true -> :unknown
         false -> String.to_atom(per.permission_group.name)
       end
     end, fn p -> String.to_atom(p.name)
     end)
    authenticate_providers = case basic_user_record.user_profile == nil do
    true -> []
    false -> credentials = [{:credential, basic_user_record.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("name"),
                            basic_user_record.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("secretkey"),
                            basic_user_record.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("email")}
              ]
              case Map.fetch(basic_user_record.user_profile.authentication_metadata, "facebook") do
                :error -> credentials
                {:ok, _value} -> credentials ++ [{:facebook, basic_user_record.user_profile.authentication_metadata |> Map.fetch!("facebook") |> Map.fetch!("name"),
                                                basic_user_record.user_profile.authentication_metadata |> Map.fetch!("facebook") |> Map.fetch!("id"),
                                                basic_user_record.user_profile.authentication_metadata |> Map.fetch!("facebook") |> Map.fetch!("email"),
                                                basic_user_record.user_profile.authentication_metadata |> Map.fetch!("facebook") |> Map.fetch!("token"),
                                                basic_user_record.user_profile.authentication_metadata |> Map.fetch!("facebook") |> Map.fetch!("expire"),
                                                }]
              end
    end
    %UserManager.Struct.User{user_schema_id: user_schema_id, user_profile_id: user_profile_id, authenticate_providers: authenticate_providers, permissions: permissions}
  end
end

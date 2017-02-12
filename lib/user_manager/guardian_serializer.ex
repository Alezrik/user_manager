defmodule UserManager.GuardianSerializer do
  @moduledoc false
  @behaviour Guardian.Serializer

  alias UserManager.Repo
  alias UserManager.Schemas.UserSchema

  def for_token(user = %UserSchema{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}
  def from_token("User:" <> id), do: {:ok, Repo.get(UserSchema, id)}
  def from_token(_), do: {:error, "Unknown resource type"}

end

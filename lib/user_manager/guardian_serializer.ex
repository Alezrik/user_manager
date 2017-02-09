defmodule UserManager.GuardianSerializer do
  @moduledoc """
  standard guardian serializer
"""
  @behaviour Guardian.Serializer

  alias UserManager.Repo
  alias UserManager.Schemas.User

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}
  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}

end
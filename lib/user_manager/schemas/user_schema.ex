defmodule UserManager.Schemas.UserSchema do
  @moduledoc """
  schema for basic user

  ## Examples

      iex>UserManager.Schemas.UserSchema.changeset(%UserManager.Schemas.UserSchema{}, %{}).valid?
      true

"""
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Bcrypt
  schema "users" do
    has_one :user_profile, UserManager.Schemas.UserProfile
    many_to_many :permissions, UserManager.Schemas.Permission, join_through: "permissions_to_users", on_replace: :delete
    timestamps()
  end
  def changeset(user, params \\ %{}) do
    cast(user, params, [])
  end
end

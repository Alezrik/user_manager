defmodule UserManager.Schemas.User do
  @moduledoc """
  schema for basic user

  ## Examples

      iex>UserManager.Schemas.User.changeset(%UserManager.Schemas.User{}, %{}).valid?
      true

"""
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Bcrypt
  schema "users" do
    has_one :user_profile, UserManager.Schemas.UserProfile
    many_to_many :permissions, UserManager.Schemas.Permission, join_through: "permissions_to_users"
    timestamps()
  end
  def changeset(user, params \\ %{}) do
    cast(user, params, [])
  end
end

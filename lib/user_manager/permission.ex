defmodule UserManager.Permission do
  @moduledoc """
  Schema for permission

  ## Usage examples

      iex>UserManager.Permission.changeset(%UserManager.Permission{}, %{"name" => Faker.Name.first_name}).valid?
      true

      iex>UserManager.Permission.changeset(%UserManager.Permission{}, %{}).valid?
      false


"""
  use Ecto.Schema
  import Ecto.Changeset
  schema "permissions" do
    field :name
    many_to_many :users, UserManager.User, join_through: "permissions_to_users"
    belongs_to :permission_group, UserManager.PermissionGroup
    timestamps()
  end
  def changeset(permission, params \\ %{}) do
    permission
    |> cast(params, [:name])
    |> validate_required(:name)
  end
end
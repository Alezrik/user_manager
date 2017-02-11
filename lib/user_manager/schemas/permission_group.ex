defmodule UserManager.Schemas.PermissionGroup do
  @moduledoc """
  schema for permission group

  ## Examples

      iex>UserManager.Schemas.PermissionGroup.changeset(%UserManager.Schemas.PermissionGroup{}, %{"name" => Faker.Name.first_name}).valid?
      true
      iex>UserManager.Schemas.PermissionGroup.changeset(%UserManager.Schemas.PermissionGroup{}, %{"name" => ""}).valid?
      false
"""
  use Ecto.Schema
  import Ecto.Changeset
  schema "permission_groups" do
    field :name
    has_many :permissions, UserManager.Schemas.Permission
    timestamps()
  end
  def changeset(permission_group, params \\ %{}) do
    permission_group
    |> cast(params, [:name])
    |> validate_required(:name)
    |> unique_constraint(:name)
  end
end

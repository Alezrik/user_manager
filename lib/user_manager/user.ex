defmodule UserManager.User do
  @moduledoc """
  schema for basic user

  ## Examples

      iex>UserManager.User.changeset(%UserManager.User{}, %{"name" => Faker.Name.first_name, "password" => <<"some_password">>}).valid?
      true

      iex>UserManager.User.changeset(%UserManager.User{}, %{"name" => "", "password" => <<"some_password">>}).valid?
      false

      iex>UserManager.User.changeset(%UserManager.User{}, %{"name" => Faker.Name.first_name, "password" => <<"">>}).valid?
      false
"""
  use Ecto.Schema
  import Ecto.Changeset
  schema "users" do
    field :name
    field :password, :binary
    many_to_many :permissions, UserManager.Permission, join_through: "permissions_to_users"
    timestamps()
  end
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :password])
    |> validate_required([:name, :password])
    |> validate_length(:name, min: 2, max: 30)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:name)
  end
end
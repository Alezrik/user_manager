defmodule UserManager.Schemas.UserProfile do
  @moduledoc """
  Schema for UserProfiles

    ## Examples

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"name"=>"fdsafdsa", "password"=>"fdsafdsafdsa", "email"=>"fdsafdsa@fdsafdsa.com"}).valid?
      true

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"name"=>"fdsafdsa", "password"=>"fdsafdsafdsa", "email"=>""}).valid?
      false

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"name"=>"fdsafdsa", "password"=>"", "email"=>"fdsafdsa@fdsafdsa.com"}).valid?
      false

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"name"=>"", "password"=>"fdsafdsafdsa", "email"=>"fdsafdsa@fdsafdsa.com"}).valid?
      false
"""

  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Bcrypt
  schema "user_profiles" do
    field :name
    field :password, :binary
    field :email
    belongs_to :user, UserManager.Schemas.User
    timestamps()
  end
  def changeset(user_profile, params \\ %{}) do
    encrypted_password = case String.length(Map.fetch!(params, "password")) < 8 do
      true -> ""
      false -> Bcrypt.hashpwsalt(Map.fetch!(params, "password"))
    end
    encrypted_params = params |> Map.put("password", encrypted_password)
    user_profile
    |> cast(encrypted_params, [:name, :password, :email])
    |> validate_required([:name, :password, :email])
    |> validate_length(:name, min: 2, max: 30)
    |> validate_length(:password, min: 8)
    |> validate_length(:email, min: 2, max: 50)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
  end
end
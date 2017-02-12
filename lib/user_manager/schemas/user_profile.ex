defmodule UserManager.Schemas.UserProfile do
  @moduledoc """
  Schema for UserProfiles

    ## Examples

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"authentication_metadata" => %{"credentials" => %{"name"=>"fdsafdsa", "password"=>"fdsafdsafdsa", "email"=>"fdsafdsa@fdsafdsa.com"}}}).valid?
      true

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"authentication_metadata" => %{"credentials" => %{"name"=>"", "password"=>"fdsafdsafdsa", "email"=>"fdsafdsa@fdsafdsa.com"}}}).valid?
      false

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"authentication_metadata" => %{"credentials" => %{"name"=>"fdsafdsa", "password"=>"", "email"=>"fdsafdsa@fdsafdsa.com"}}}).valid?
      false

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{"authentication_metadata" => %{"credentials" => %{"name"=>"fdsafdsa", "password"=>"fdsafdsafdsa", "email"=>""}}}).valid?
      false

      iex>UserManager.Schemas.UserProfile.changeset(%UserManager.Schemas.UserProfile{}, %{}).valid?
      false
"""
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Bcrypt
  require Logger
  schema "user_profiles" do
    field :authentication_metadata, :map
    belongs_to :user_schema, UserManager.Schemas.UserSchema
    timestamps()
  end
  def changeset(user_profile, params \\ %{}) do
    metadata = Map.get(params, "authentication_metadata", %{})
    credential_metadata = Map.get(metadata, "credentials", %{})
    encrypted_password_credentials = case credential_metadata do
      i when map_size(i) < 1 -> %{}
      map ->
      password =  Map.get(map, "password", "")
      password = case String.length(password) < 8 do
        true -> ""
        false -> Bcrypt.hashpwsalt(password)
      end
      Map.put(map, "password", password)
    end
    updated_metadata = case metadata do
      i when map_size(i) < 1 -> params
      value -> case credential_metadata do
                :error ->
                params
                cred ->
                  credentials = Map.merge(cred, encrypted_password_credentials)
                  Map.merge(params, %{"authentication_metadata" => %{"credentials" => credentials}})
                end
    end
    user_profile
    |> cast(updated_metadata, [:authentication_metadata])
    |> validate_required([:authentication_metadata])
    |> validate_params()
  end
  def validate_duplicate(changeset) do
    md = case get_field(changeset, :authentication_metadata) do
          nil -> :error
          something -> Map.fetch!(something, "credentials")
        end
    case md do
      :error -> changeset
      v -> username = Map.get(v, "name", "")
            email = Map.get(v, "email", "")
       case GenServer.call(UserManager.UserRepo, {:validate_credential_name_email, username, email}) do
         :ok -> changeset
         :duplicate -> add_error(changeset, :authentication_metadata, "name and email must be unique")
       end
    end
  end
  def validate_params(changeset, authentication_provider \\ "credentials") do
    md = case get_field(changeset, :authentication_metadata) do
      nil -> %{}
      something -> Map.fetch!(something, "credentials")
    end
    required_fields = [{:name, 6}, {:password, 8}, {:email, 8}]
    Enum.reduce(required_fields, changeset, fn {tag, len}, acc ->
      case Map.fetch(md, Atom.to_string(tag)) do
        :error ->  add_error(acc, tag, Atom.to_string(tag) <> " is a required field")
        {:ok, item} ->
          verify_length(item, len, tag, acc)
      end
     end)
  end
  defp verify_length(str_field, length, tag, changeset) do
    case String.length(str_field) < length do
      true ->
        add_error(changeset, tag, Atom.to_string(tag) <> "requires a length of #{length}")
      false -> changeset
    end
  end
end

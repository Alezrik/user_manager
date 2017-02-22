defmodule UserManager.Schemas.UserProfile do
  @moduledoc """
  Schema for UserProfiles
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
  @doc """
  setup changeset for user_profile

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
  def changeset(user_profile, params \\ %{}) do
    user_profile
    |> cast(params, [:authentication_metadata])
    |> validate_required(:authentication_metadata)
    |> validate_credentials
  end
  defp validate_credentials(changeset) do
    changeset
    |> validate_credentials_exist(:authentication_metadata)
    |> validate_credentials_field_exists(:authentication_metadata, "name")
    |> validate_password_or_encrypted_exists(:authentication_metadata, "password", "secretkey")
    |> validate_credentials_field_exists(:authentication_metadata, "email")
    |> validate_credentials_field_min_length(:authentication_metadata, "password", 8)
    |> validate_credentials_field_min_length(:authentication_metadata, "name", 6)
    |> validate_credentials_field_min_length(:authentication_metadata, "email", 2)
    |> encrypt_password_to_key(:authentication_metadata, "password", "secretkey")
    |> validate_facebook_field_exists(:authentication_metadata, "name")
    |> validate_facebook_field_exists(:authentication_metadata, "email")
    |> validate_facebook_field_exists(:authentication_metadata, "expire")
    |> validate_facebook_field_exists(:authentication_metadata, "token")
    |> validate_facebook_field_exists(:authentication_metadata, "id")
    |> encrypt_facebook_field(:authentication_metadata, "token")
    |> encrypt_facebook_field(:authentication_metadata, "id")
    |> encrypt_facebook_field(:authentication_metadata, "expire")
  end
  defp encrypt_facebook_field(changeset, field, field_name) do
    case fetch_field(changeset, field) do
          :error -> changeset
          {_, nil} -> changeset
          {_, ch} -> case Map.fetch(ch, "facebook") do
            :error -> changeset
            {_, f} -> process_facebook_encrypt_field(changeset, field, ch, f, field_name)
          end
        end
  end
  defp process_facebook_encrypt_field(changeset, field,  field_map, facebook_map, field_name) do
    case Map.fetch(facebook_map, field_name) do
      :error -> changeset
      {_, v} -> encrypted = Cipher.encrypt(v)
        encrypted = field_map |> Map.fetch!("facebook") |> Map.put(field_name, encrypted)
        new_credentials = Map.put(field_map, "facebook", encrypted)
        put_change(changeset, field, new_credentials)
     end
  end
  defp validate_facebook_field_exists(changeset, field, field_name) do
    case fetch_field(changeset, field) do
      :error -> add_error(changeset, field, "credentials do not exist!")
      {_, nil} -> add_error(changeset, field, "credentials do not exist!")
      {_, ch} -> case Map.fetch(ch, "facebook") do
        :error -> changeset
        {_, f} -> process_facebook_field_exists(changeset, field, f, field_name)
        end
      end
  end
  defp process_facebook_field_exists(changeset, field, facebook_map, field_name) do
    case Map.fetch(facebook_map, field_name) do
      :error -> add_error(changeset, field, "facebook is missing #{field_name}")
      {_, _v} -> changeset
      end
  end
  defp validate_password_or_encrypted_exists(changeset, field, password_field, encrypted_password_field) do
    case fetch_field(changeset, field) do
      :error -> add_error(changeset, field, "credentials do not exist!")
      {_, nil} -> add_error(changeset, field, "credentials do not exist!")
      {_, ch} -> case ch |> Map.get("credentials", %{}) |> Map.get(password_field, encrypted_password_field) do
        nil -> add_error(changeset, field, "password does not exist!")
        _item -> changeset
      end
    end
  end
  defp encrypt_password_to_key(changeset, field, raw_password, destination_encrypt) do
    case fetch_field(changeset, field) do
      :error -> changeset
      {_, nil} -> changeset
      {_, ch} -> case ch |> Map.get("credentials", %{}) |> Map.get(raw_password, "") do
        "" -> changeset
        passwd ->
          new_field = ch |> Map.fetch!("credentials") |> Map.put(destination_encrypt, Bcrypt.hashpwsalt(passwd)) |> Map.delete(raw_password)
          new_credentials =  Map.put(ch, "credentials", new_field)
          put_change(changeset, field, new_credentials)
      end
    end
  end
  defp validate_credentials_exist(changeset, field) do
    case fetch_field(changeset, field) do
      :error -> add_error(changeset, field, "credentials do not exist")
      {_, nil} -> add_error(changeset, field, "credentials do not exist")
      {_, credentials} ->
          case Map.get(credentials, "credentials", %{}) do
        i when map_size(i) < 1 -> add_error(changeset, field, "credentials do not exist")
        _other -> changeset
      end
    end
  end
  defp validate_credentials_field_exists(changeset, field, credentials_field) do
    case fetch_field(changeset, field) do
      :error -> add_error(changeset, field, "#{credentials_field} does not exist")
      {_, nil} -> add_error(changeset, field, "#{credentials_field} does not exist")
      {_, ch} -> case ch |> Map.get("credentials", %{}) |> Map.fetch(credentials_field) do
        :error -> add_error(changeset, field, "#{credentials_field} does not exist")
        _success -> changeset
      end
    end
  end
  defp validate_credentials_field_min_length(changeset, field, credentials_field, length) do
    case fetch_field(changeset, field) do
      :error -> changeset
      {_, nil} -> changeset
      {_, ch} -> case ch |> Map.get("credentials", %{}) |> Map.fetch(credentials_field) do
        :error -> changeset
        {:ok, value} -> validate_string_len(changeset, field, value, credentials_field, length)
      end
    end
  end
  defp validate_string_len(changeset, field, str, credentials_field, length) do
    case String.length(str) >= length do
      true -> changeset
      false -> add_error(changeset, field, "#{credentials_field} requires a min length of: #{length}")
    end
  end
end

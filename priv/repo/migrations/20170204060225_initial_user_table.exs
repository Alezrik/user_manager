defmodule UserManager.Repo.Migrations.InitialUserTable do
  use Ecto.Migration

  def change do
    create table :users do
      add :name, :string, size: 30
      add :password, :binary
      timestamps()
    end
    create unique_index(:users, :name)
    create table(:guardian_tokens, primary_key: false) do
      add :jti, :string, primary_key: true
      add :aud, :string, primary_key: true
      add :typ, :string
      add :iss, :string
      add :sub, :string
      add :exp, :bigint
      add :jwt, :text
      add :claims, :map
      timestamps()
    end
    create table(:permission_groups) do
      add :name, :string, size: 30
      timestamps()
    end
    create unique_index(:permission_groups, :name)

    create table(:permissions) do
      add :name, :string
      add :permission_group_id, references(:permission_groups)
      timestamps()
    end
    create table(:permissions_to_users, primary_key: false) do
      add :user_id, references(:users)
      add :permission_id, references(:permissions)
    end

  end
end

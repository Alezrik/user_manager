defmodule UserManager.Repo.Migrations.CreateUserProfile do
  use Ecto.Migration

  def change do
    drop index(:users, :name)
    alter table :users do
      remove :name
      remove :password
    end

    create table :user_profiles do
      add :name, :string, size: 30
      add :password, :binary
      add :email, :string, size: 50
      add :user_id, references(:users)
      timestamps()
    end
    create unique_index(:user_profiles, :name)
    create unique_index(:user_profiles, :email)
  end
end

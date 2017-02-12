defmodule UserManager.Repo.Migrations.ExtendUserProfiles do
  use Ecto.Migration

  def change do
    alter table(:user_profiles) do
      add :authentication_metadata, :map
    end
    drop index(:user_profiles, :name)
    drop index(:user_profiles, :email)
    alter table(:user_profiles) do
      remove :name
      remove :password
      remove :email
      remove :user_id
      add :user_schema_id, references(:users)
    end
    alter table(:permissions_to_users) do
      remove :user_id
      add :user_schema_id, references(:users)
    end

  end

end

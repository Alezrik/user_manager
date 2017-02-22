defmodule UserManager.Repo.Migrations.CascadeDelete do
  use Ecto.Migration

  def change do
    alter table(:permissions_to_users) do
      remove :user_schema_id
      add :user_schema_id, references(:users, on_delete: :delete_all)
    end
    alter table(:user_profiles) do
      remove :user_schema_id
      add :user_schema_id, references(:users, on_delete: :delete_all)
    end
  end
end

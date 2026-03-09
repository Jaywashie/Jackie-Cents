defmodule Insurance.Repo.Migrations.AddUserIdToQuotes do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:quotes, [:user_id])
  end
end

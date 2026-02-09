defmodule Insurance.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :name, :string
      add :email, :string
      add :type, :string

      timestamps()
    end

    create unique_index(:quotes, [:email])
  end
end

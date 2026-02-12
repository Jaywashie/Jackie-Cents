defmodule Insurance.Repo.Migrations.CreatePolicies do
  use Ecto.Migration

  def change do
    create table(:policies) do
      add :policy_number, :string
      add :customer_id, :integer
      add :plan, :string
      add :premium, :decimal
      add :status, :string
      add :start_date, :date
      add :end_date, :date

      timestamps()
    end
  end
end

defmodule Insurance.Repo.Migrations.AddPensionFieldsToQuotes do
  use Ecto.Migration

def change do
  alter table(:quotes) do
    add :plan_name, :string
    add :plan_type, :string
    add :monthly_contribution, :integer
    add :estimated_value, :integer
  end
end
end

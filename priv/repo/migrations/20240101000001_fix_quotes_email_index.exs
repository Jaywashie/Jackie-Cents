defmodule Insurance.Repo.Migrations.FixQuotesEmailIndex do
  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:quotes, [:email], name: :quotes_email_index)
    create_if_not_exists index(:quotes, [:email], name: :quotes_email_index)
  end

  def down do
    drop_if_exists index(:quotes, [:email], name: :quotes_email_index)
    create_if_not_exists unique_index(:quotes, [:email], name: :quotes_email_index)
  end
end

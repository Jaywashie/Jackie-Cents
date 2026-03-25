defmodule Insurance.Repo.Migrations.AddNewPlanTypesToQuotes do
  use Ecto.Migration

  @moduledoc """
  The `plan_type` field on the `quotes` table is a plain :string (varchar).
  It is validated at the application level in the Quote changeset, NOT via a
  database-level CHECK constraint or ENUM type — so no ALTER TABLE is strictly
  required for the 6 new plan types.

  However, this migration adds a database-level CHECK constraint to document
  the full set of valid plan types and prevent invalid data from entering
  the database directly (e.g. via psql or scripts).

  Run with:   mix ecto.migrate
  Rollback:   mix ecto.rollback
  """

  def up do
    # Drop any existing check constraint on plan_type (if one exists from a prior migration)
    execute """
    ALTER TABLE quotes
      DROP CONSTRAINT IF EXISTS quotes_plan_type_check;
    """

    # Add an updated CHECK constraint covering all current + new plan types
    execute """
    ALTER TABLE quotes
      ADD CONSTRAINT quotes_plan_type_check
      CHECK (plan_type IN (
        'life',
        'medical',
        'motor',
        'pension',
        'unit_trust',
        'money_market',
        'sme',
        'wiba',
        'travel',
        'marine',
        'group_life',
        'afya_tele',
        'last_expense',
        'amani_shield'
      ));
    """
  end

  def down do
    execute """
    ALTER TABLE quotes
      DROP CONSTRAINT IF EXISTS quotes_plan_type_check;
    """

    # Restore original constraint (original 8 plan types only)
    execute """
    ALTER TABLE quotes
      ADD CONSTRAINT quotes_plan_type_check
      CHECK (plan_type IN (
        'life',
        'medical',
        'motor',
        'pension',
        'unit_trust',
        'money_market',
        'sme',
        'wiba'
      ));
    """
  end
end

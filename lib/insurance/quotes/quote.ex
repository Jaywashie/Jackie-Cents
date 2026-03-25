defmodule Insurance.Quotes.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do
    field :plan_name,            :string
    field :plan_type,            :string
    field :email,                :string
    field :monthly_contribution, :integer
    field :estimated_value,      :integer
    belongs_to :user, Insurance.Accounts.User

    timestamps()
  end

  # Original types + 6 new plan types
  @valid_plan_types ~w(
    life medical motor pension unit_trust money_market sme wiba
    travel marine group_life afya_tele last_expense amani_shield
  )

  @required_fields ~w(user_id plan_name plan_type email monthly_contribution estimated_value)a

  def changeset(quote, attrs) do
    quote
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:plan_name, max: 255)
    |> validate_inclusion(:plan_type, @valid_plan_types)
  end
end

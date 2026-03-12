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

  @required_fields ~w(user_id plan_name plan_type email monthly_contribution estimated_value)a

  def changeset(quote, attrs) do
    quote
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:plan_name, max: 255)
    |> validate_inclusion(:plan_type, ~w(life medical motor pension))
    # NOTE: No unique_constraint here — a user is allowed to save
    # as many quotes as they want, including duplicates.
  end
end

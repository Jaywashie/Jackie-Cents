defmodule Insurance.Quotes.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do
    field :plan_name, :string
    field :plan_type, :string
    field :email, :string
    field :monthly_contribution, :integer
    field :estimated_value, :integer

    belongs_to :user, Insurance.Accounts.User

    timestamps()
  end

  @valid_plan_types ~w(medical life motor pension)

  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:user_id, :plan_name, :plan_type, :email,
                    :monthly_contribution, :estimated_value])
    |> validate_required([:user_id, :plan_name, :plan_type, :email])
    |> validate_inclusion(:plan_type, @valid_plan_types)
    |> validate_number(:monthly_contribution, greater_than: 0)
    |> validate_number(:estimated_value, greater_than: 0)
    |> assoc_constraint(:user)
  end
end

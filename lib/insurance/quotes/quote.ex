defmodule Insurance.Quotes.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do

  field :plan_name, :string
  field :plan_type, :string
  field :monthly_contribution, :integer
  field :estimated_value, :integer
  field :email, :string

  belongs_to :user, Insurance.Accounts.User

    timestamps()

  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:plan_name, :email, :plan_type, :monthly_contribution, :estimated_value, :user_id])
    |> validate_required([:plan_name, :email, :plan_type, :monthly_contribution, :estimated_value, :user_id])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, message: "Email already exists")
  end
end

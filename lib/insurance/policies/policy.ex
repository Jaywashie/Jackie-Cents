defmodule Insurance.Policies.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "policies" do
  field :policy_number, :string
  field :plan, :string
  field :premium, :decimal
  field :status, :string, default: "active"
  field :start_date, :date
  field :end_date, :date

  belongs_to :customer, Insurance.Accounts.User
    timestamps()
  end

  @doc false

  def changeset(policy, attrs) do
  policy
  |> cast(attrs, [
    :policy_number,
    :plan,
    :premium,
    :status,
    :start_date,
    :end_date,
    :customer_id
  ])
  |> validate_required([
    :policy_number,
    :plan,
    :premium,
    :start_date,
    :end_date,
    :customer_id
  ])
end
end

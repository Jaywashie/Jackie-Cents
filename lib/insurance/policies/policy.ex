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

    belongs_to :user, Insurance.Accounts.User

    timestamps()
  end

  @valid_statuses ~w(active expired cancelled)

  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [:user_id, :policy_number, :plan, :premium,
                    :status, :start_date, :end_date])
    |> validate_required([:user_id, :policy_number, :plan, :premium,
                          :start_date, :end_date])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:premium, greater_than: 0)
    |> unique_constraint(:policy_number)
    |> assoc_constraint(:user)
  end
end

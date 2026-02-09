defmodule Insurance.Quotes.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do
    field :name, :string
    field :type, :string
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:name, :email, :type])
    |> validate_required([:name, :email, :type])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, message: "Email already exists")
  end
end

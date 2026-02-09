defmodule Insurance.PoliciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Insurance.Policies` context.
  """

  @doc """
  Generate a quote.
  """
  def quote_fixture(attrs \\ %{}) do
    {:ok, quote} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        type: "some type"
      })
      |> Insurance.Policies.create_quote()

    quote
  end
end

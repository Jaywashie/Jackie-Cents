defmodule Insurance.QuotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Insurance.Quotes` context.
  """

  @doc """
  Generate a q.
  """
  def q_fixture(attrs \\ %{}) do
    {:ok, q} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        type: "some type"
      })
      |> Insurance.Quotes.create_q()

    q
  end
end

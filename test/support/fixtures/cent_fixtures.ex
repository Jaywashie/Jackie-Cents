defmodule Insurance.CentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Insurance.Cent` context.
  """

  @doc """
  Generate a quotes.
  """
  def quotes_fixture(attrs \\ %{}) do
    {:ok, quotes} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        type: "some type"
      })
      |> Insurance.Cent.create_quotes()

    quotes
  end
end

defmodule Insurance.PoliciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Insurance.Policies` context.
  """

  @doc """
  Generate a policy.
  """
  def policy_fixture(attrs \\ %{}) do
    {:ok, policy} =
      attrs
      |> Enum.into(%{
        customer_id: 42,
        end_date: ~D[2026-02-08],
        plan: "some plan",
        policy_number: "some policy_number",
        premium: "120.5",
        start_date: ~D[2026-02-08],
        status: "some status"
      })
      |> Insurance.Policies.create_policy()

    policy
  end
end

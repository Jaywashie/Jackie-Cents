defmodule Insurance.PoliciesTest do
  use Insurance.DataCase

  alias Insurance.Policies

  describe "policies" do
    alias Insurance.Policies.Policy

    import Insurance.PoliciesFixtures

    @invalid_attrs %{"\\": nil}

    test "list_policies/0 returns all policies" do
      policy = policy_fixture()
      assert Policies.list_policies() == [policy]
    end

    test "get_policy!/1 returns the policy with given id" do
      policy = policy_fixture()
      assert Policies.get_policy!(policy.id) == policy
    end

    test "create_policy/1 with valid data creates a policy" do
      valid_attrs = %{"\\": "some \\"}

      assert {:ok, %Policy{} = policy} = Policies.create_policy(valid_attrs)
      assert policy.\ == "some \\"
    end

    test "create_policy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Policies.create_policy(@invalid_attrs)
    end

    test "update_policy/2 with valid data updates the policy" do
      policy = policy_fixture()
      update_attrs = %{"\\": "some updated \\"}

      assert {:ok, %Policy{} = policy} = Policies.update_policy(policy, update_attrs)
      assert policy.\ == "some updated \\"
    end

    test "update_policy/2 with invalid data returns error changeset" do
      policy = policy_fixture()
      assert {:error, %Ecto.Changeset{}} = Policies.update_policy(policy, @invalid_attrs)
      assert policy == Policies.get_policy!(policy.id)
    end

    test "delete_policy/1 deletes the policy" do
      policy = policy_fixture()
      assert {:ok, %Policy{}} = Policies.delete_policy(policy)
      assert_raise Ecto.NoResultsError, fn -> Policies.get_policy!(policy.id) end
    end

    test "change_policy/1 returns a policy changeset" do
      policy = policy_fixture()
      assert %Ecto.Changeset{} = Policies.change_policy(policy)
    end
  end

  describe "policies" do
    alias Insurance.Policies.Policy

    import Insurance.PoliciesFixtures

    @invalid_attrs %{status: nil, plan: nil, policy_number: nil, customer_id: nil, premium: nil, start_date: nil, end_date: nil}

    test "list_policies/0 returns all policies" do
      policy = policy_fixture()
      assert Policies.list_policies() == [policy]
    end

    test "get_policy!/1 returns the policy with given id" do
      policy = policy_fixture()
      assert Policies.get_policy!(policy.id) == policy
    end

    test "create_policy/1 with valid data creates a policy" do
      valid_attrs = %{status: "some status", plan: "some plan", policy_number: "some policy_number", customer_id: 42, premium: "120.5", start_date: ~D[2026-02-08], end_date: ~D[2026-02-08]}

      assert {:ok, %Policy{} = policy} = Policies.create_policy(valid_attrs)
      assert policy.status == "some status"
      assert policy.plan == "some plan"
      assert policy.policy_number == "some policy_number"
      assert policy.customer_id == 42
      assert policy.premium == Decimal.new("120.5")
      assert policy.start_date == ~D[2026-02-08]
      assert policy.end_date == ~D[2026-02-08]
    end

    test "create_policy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Policies.create_policy(@invalid_attrs)
    end

    test "update_policy/2 with valid data updates the policy" do
      policy = policy_fixture()
      update_attrs = %{status: "some updated status", plan: "some updated plan", policy_number: "some updated policy_number", customer_id: 43, premium: "456.7", start_date: ~D[2026-02-09], end_date: ~D[2026-02-09]}

      assert {:ok, %Policy{} = policy} = Policies.update_policy(policy, update_attrs)
      assert policy.status == "some updated status"
      assert policy.plan == "some updated plan"
      assert policy.policy_number == "some updated policy_number"
      assert policy.customer_id == 43
      assert policy.premium == Decimal.new("456.7")
      assert policy.start_date == ~D[2026-02-09]
      assert policy.end_date == ~D[2026-02-09]
    end

    test "update_policy/2 with invalid data returns error changeset" do
      policy = policy_fixture()
      assert {:error, %Ecto.Changeset{}} = Policies.update_policy(policy, @invalid_attrs)
      assert policy == Policies.get_policy!(policy.id)
    end

    test "delete_policy/1 deletes the policy" do
      policy = policy_fixture()
      assert {:ok, %Policy{}} = Policies.delete_policy(policy)
      assert_raise Ecto.NoResultsError, fn -> Policies.get_policy!(policy.id) end
    end

    test "change_policy/1 returns a policy changeset" do
      policy = policy_fixture()
      assert %Ecto.Changeset{} = Policies.change_policy(policy)
    end
  end
end

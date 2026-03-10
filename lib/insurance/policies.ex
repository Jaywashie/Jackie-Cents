defmodule Insurance.Policies do
  import Ecto.Query
  alias Insurance.Repo
  alias Insurance.Policies.Policy

  def list_policies do
    Repo.all(from p in Policy, order_by: [desc: p.inserted_at])
  end

  def list_policies_for_user(user_id) do
    Repo.all(
      from p in Policy,
        where: p.user_id == ^user_id,
        order_by: [desc: p.start_date]
    )
  end

  def get_policy!(id), do: Repo.get!(Policy, id)

  def create_policy(attrs \\ %{}) do
    %Policy{}
    |> Policy.changeset(attrs)
    |> Repo.insert()
  end

  def update_policy(%Policy{} = policy, attrs) do
    policy
    |> Policy.changeset(attrs)
    |> Repo.update()
  end

  def delete_policy(%Policy{} = policy), do: Repo.delete(policy)

  def change_policy(%Policy{} = policy, attrs \\ %{}) do
    Policy.changeset(policy, attrs)
  end

  # Auto-expire policies where end_date has passed
  def expire_old_policies do
    today = Date.utc_today()
    Repo.update_all(
      from(p in Policy, where: p.end_date < ^today and p.status == "active"),
      set: [status: "expired"]
    )
  end
end

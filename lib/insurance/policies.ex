defmodule Insurance.Policies do
  @moduledoc """
  The Policies context.
  """

  import Ecto.Query, warn: false
  alias Insurance.Repo

  alias Insurance.Policies.Policy

  @doc """
  Returns the list of policies.

  ## Examples

      iex> list_policies()
      [%Policy{}, ...]

  """
  def list_policies do
    Repo.all(Policy)
  end

  @doc """
  Gets a single policy.

  Raises `Ecto.NoResultsError` if the Policy does not exist.

  ## Examples

      iex> get_policy!(123)
      %Policy{}

      iex> get_policy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_policy!(id), do: Repo.get!(Policy, id)

  @doc """
  Creates a policy.

  ## Examples

      iex> create_policy(%{field: value})
      {:ok, %Policy{}}

      iex> create_policy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def create_policy(attrs) do
  attrs =
    Map.put(attrs, "status", calculate_status(attrs["end_date"]))

  %Policy{}
  |> Policy.changeset(attrs)
  |> Repo.insert()
end

defp calculate_status(end_date) do
  if  Date.compare(Date.from_iso8601!(end_date), Date.utc_today()) == :lt do
    "expired"
  else
    "active"
  end
end


  @doc """
  Updates a policy.

  ## Examples

      iex> update_policy(policy, %{field: new_value})
      {:ok, %Policy{}}

      iex> update_policy(policy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_policy(%Policy{} = policy, attrs) do
    policy
    |> Policy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a policy.

  ## Examples

      iex> delete_policy(policy)
      {:ok, %Policy{}}

      iex> delete_policy(policy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_policy(%Policy{} = policy) do
    Repo.delete(policy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking policy changes.

  ## Examples

      iex> change_policy(policy)
      %Ecto.Changeset{data: %Policy{}}

  """
  def change_policy(%Policy{} = policy, attrs \\ %{}) do
    Policy.changeset(policy, attrs)
  end
end

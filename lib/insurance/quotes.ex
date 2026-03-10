defmodule Insurance.Quotes do
  import Ecto.Query
  alias Insurance.Repo
  alias Insurance.Quotes.Quote

  def list_quotes do
    Repo.all(from q in Quote, order_by: [desc: q.inserted_at])
  end

  def list_quotes_for_user(user_id) do
    Repo.all(
      from q in Quote,
        where: q.user_id == ^user_id,
        order_by: [desc: q.inserted_at]
    )
  end

  def list_quotes_for_user_by_type(user_id, plan_type) do
  Repo.all(
    from q in Quote,
      where: q.user_id == ^user_id and q.plan_type == ^plan_type,
      order_by: [desc: q.inserted_at]
  )
end


  def get_quote!(id), do: Repo.get!(Quote, id)

  def create_quote(attrs \\ %{}) do
    %Quote{}
    |> Quote.changeset(attrs)
    |> Repo.insert()
  end

  def delete_quote(%Quote{} = quote), do: Repo.delete(quote)

  # Useful for AdminLive stats
  def count_by_plan_type do
    Repo.all(
      from q in Quote,
        group_by: q.plan_type,
        select: {q.plan_type, count(q.id)}
    )
    |> Map.new()
  end
end

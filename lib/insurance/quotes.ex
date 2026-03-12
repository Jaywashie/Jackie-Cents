defmodule Insurance.Quotes do
  import Ecto.Query
  alias Insurance.Repo
  alias Insurance.Quotes.Quote

  def create_quote(attrs \\ %{}) do
    require Logger

    changeset = Quote.changeset(%Quote{}, attrs)

    unless changeset.valid? do
      Logger.error("Quotes.create_quote -- invalid changeset: #{inspect(changeset.errors)}")
    end

    case Repo.insert(changeset) do
      {:ok, quote} ->
        {:ok, quote}

      {:error, %Ecto.Changeset{} = cs} ->
        Logger.error("Quotes.create_quote -- changeset errors: #{inspect(cs.errors)}")
        {:error, cs}

      other ->
        Logger.error("Quotes.create_quote -- unexpected result: #{inspect(other)}")
        {:error, :unexpected}
    end
  rescue
    e in Ecto.ConstraintError ->
      Logger.error("Quotes.create_quote -- UNIQUE CONSTRAINT still on table. Run migration. #{inspect(e)}")
      {:error, :constraint}

    e ->
      Logger.error("Quotes.create_quote -- exception: #{inspect(e)}")
      {:error, :exception}
  end

  def list_quotes do
    Quote
    |> order_by([q], desc: q.inserted_at)
    |> Repo.all()
  end

  def list_quotes_for_user(user_id) do
    Quote
    |> where([q], q.user_id == ^user_id)
    |> order_by([q], desc: q.inserted_at)
    |> Repo.all()
  end

  # Used by the filter buttons on MyQuotesLive
  def list_quotes_for_user_by_type(user_id, plan_type) do
    Quote
    |> where([q], q.user_id == ^user_id and q.plan_type == ^plan_type)
    |> order_by([q], desc: q.inserted_at)
    |> Repo.all()
  end

  def get_quote!(id), do: Repo.get!(Quote, id)

  def delete_quote(%Quote{} = quote), do: Repo.delete(quote)
end

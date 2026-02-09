defmodule Insurance.CentTest do
  use Insurance.DataCase

  alias Insurance.Cent

  describe "quote" do
    alias Insurance.Cent.Quotes

    import Insurance.CentFixtures

    @invalid_attrs %{name: nil, type: nil, email: nil}

    test "list_quote/0 returns all quote" do
      quotes = quotes_fixture()
      assert Cent.list_quote() == [quotes]
    end

    test "get_quotes!/1 returns the quotes with given id" do
      quotes = quotes_fixture()
      assert Cent.get_quotes!(quotes.id) == quotes
    end

    test "create_quotes/1 with valid data creates a quotes" do
      valid_attrs = %{name: "some name", type: "some type", email: "some email"}

      assert {:ok, %Quotes{} = quotes} = Cent.create_quotes(valid_attrs)
      assert quotes.name == "some name"
      assert quotes.type == "some type"
      assert quotes.email == "some email"
    end

    test "create_quotes/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cent.create_quotes(@invalid_attrs)
    end

    test "update_quotes/2 with valid data updates the quotes" do
      quotes = quotes_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type", email: "some updated email"}

      assert {:ok, %Quotes{} = quotes} = Cent.update_quotes(quotes, update_attrs)
      assert quotes.name == "some updated name"
      assert quotes.type == "some updated type"
      assert quotes.email == "some updated email"
    end

    test "update_quotes/2 with invalid data returns error changeset" do
      quotes = quotes_fixture()
      assert {:error, %Ecto.Changeset{}} = Cent.update_quotes(quotes, @invalid_attrs)
      assert quotes == Cent.get_quotes!(quotes.id)
    end

    test "delete_quotes/1 deletes the quotes" do
      quotes = quotes_fixture()
      assert {:ok, %Quotes{}} = Cent.delete_quotes(quotes)
      assert_raise Ecto.NoResultsError, fn -> Cent.get_quotes!(quotes.id) end
    end

    test "change_quotes/1 returns a quotes changeset" do
      quotes = quotes_fixture()
      assert %Ecto.Changeset{} = Cent.change_quotes(quotes)
    end
  end
end

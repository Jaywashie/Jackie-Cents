defmodule Insurance.PoliciesTest do
  use Insurance.DataCase

  alias Insurance.Policies

  describe "quotes" do
    alias Insurance.Policies.Quote

    import Insurance.PoliciesFixtures

    @invalid_attrs %{name: nil, type: nil, email: nil}

    test "list_quotes/0 returns all quotes" do
      quote = quote_fixture()
      assert Policies.list_quotes() == [quote]
    end

    test "get_quote!/1 returns the quote with given id" do
      quote = quote_fixture()
      assert Policies.get_quote!(quote.id) == quote
    end

    test "create_quote/1 with valid data creates a quote" do
      valid_attrs = %{name: "some name", type: "some type", email: "some email"}

      assert {:ok, %Quote{} = quote} = Policies.create_quote(valid_attrs)
      assert quote.name == "some name"
      assert quote.type == "some type"
      assert quote.email == "some email"
    end

    test "create_quote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Policies.create_quote(@invalid_attrs)
    end

    test "update_quote/2 with valid data updates the quote" do
      quote = quote_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type", email: "some updated email"}

      assert {:ok, %Quote{} = quote} = Policies.update_quote(quote, update_attrs)
      assert quote.name == "some updated name"
      assert quote.type == "some updated type"
      assert quote.email == "some updated email"
    end

    test "update_quote/2 with invalid data returns error changeset" do
      quote = quote_fixture()
      assert {:error, %Ecto.Changeset{}} = Policies.update_quote(quote, @invalid_attrs)
      assert quote == Policies.get_quote!(quote.id)
    end

    test "delete_quote/1 deletes the quote" do
      quote = quote_fixture()
      assert {:ok, %Quote{}} = Policies.delete_quote(quote)
      assert_raise Ecto.NoResultsError, fn -> Policies.get_quote!(quote.id) end
    end

    test "change_quote/1 returns a quote changeset" do
      quote = quote_fixture()
      assert %Ecto.Changeset{} = Policies.change_quote(quote)
    end
  end
end

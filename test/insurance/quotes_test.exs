defmodule Insurance.QuotesTest do
  use Insurance.DataCase

  alias Insurance.Quotes

  describe "uote" do
    alias Insurance.Quotes.Q

    import Insurance.QuotesFixtures

    @invalid_attrs %{name: nil, type: nil, email: nil}

    test "list_uote/0 returns all uote" do
      q = q_fixture()
      assert Quotes.list_uote() == [q]
    end

    test "get_q!/1 returns the q with given id" do
      q = q_fixture()
      assert Quotes.get_q!(q.id) == q
    end

    test "create_q/1 with valid data creates a q" do
      valid_attrs = %{name: "some name", type: "some type", email: "some email"}

      assert {:ok, %Q{} = q} = Quotes.create_q(valid_attrs)
      assert q.name == "some name"
      assert q.type == "some type"
      assert q.email == "some email"
    end

    test "create_q/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quotes.create_q(@invalid_attrs)
    end

    test "update_q/2 with valid data updates the q" do
      q = q_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type", email: "some updated email"}

      assert {:ok, %Q{} = q} = Quotes.update_q(q, update_attrs)
      assert q.name == "some updated name"
      assert q.type == "some updated type"
      assert q.email == "some updated email"
    end

    test "update_q/2 with invalid data returns error changeset" do
      q = q_fixture()
      assert {:error, %Ecto.Changeset{}} = Quotes.update_q(q, @invalid_attrs)
      assert q == Quotes.get_q!(q.id)
    end

    test "delete_q/1 deletes the q" do
      q = q_fixture()
      assert {:ok, %Q{}} = Quotes.delete_q(q)
      assert_raise Ecto.NoResultsError, fn -> Quotes.get_q!(q.id) end
    end

    test "change_q/1 returns a q changeset" do
      q = q_fixture()
      assert %Ecto.Changeset{} = Quotes.change_q(q)
    end
  end
end

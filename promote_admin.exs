# promote_admin.exs
alias Insurance.{Accounts, Repo, Accounts.User}

email = "jaywashie5735@gmail.com"
password = "123456789012"

case Accounts.get_user_by_email(email) do
  nil ->
    attrs = %{
      email: email,
      password: password,
      first_name: "Admin",
      last_name: "User",
      phone_number: "0700000000"
    }
    case Accounts.register_user(attrs) do
      {:ok, user} ->
        user |> User.confirm_changeset() |> Repo.update!()
        {:ok, _} = Accounts.promote_to_admin(user)
        IO.puts("✅ Created and promoted new admin: #{email}")
      {:error, cs} ->
        IO.puts("❌ Failed to create user:")
        IO.inspect(cs.errors)
    end

  user ->
    user |> User.confirm_changeset() |> Repo.update!()
    {:ok, _} = Accounts.promote_to_admin(user)
    IO.puts("✅ Promoted existing user to admin: #{email}")
end

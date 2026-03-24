# priv/repo/seeds.exs
alias Insurance.Accounts
alias Insurance.Repo

admin_email    = System.get_env("ADMIN_EMAIL", "JackieCents23@gmail.com")
admin_password = System.get_env("ADMIN_PASSWORD", "123456789012")

case Accounts.get_user_by_email(admin_email) do
  nil ->
    attrs = %{
      email: admin_email,
      password: admin_password,
      first_name: "Admin",
      last_name: "User",
      phone_number: "0700000000"
    }
    case Accounts.register_user(attrs) do
      {:ok, user} ->
        # Confirm the user so they can log in immediately
        user |> Insurance.Accounts.User.confirm_changeset() |> Repo.update!()
        {:ok, _} = Accounts.promote_to_admin(user)
        IO.puts("✅ Admin user created and confirmed: #{admin_email}")

      {:error, changeset} ->
        IO.puts("❌ Failed to create admin user: #{inspect(changeset.errors)}")
    end

  existing ->
    # Ensure existing user is confirmed and promoted
    existing |> Insurance.Accounts.User.confirm_changeset() |> Repo.update!()
    {:ok, _} = Accounts.promote_to_admin(existing)
    IO.puts("✅ Existing user confirmed and promoted to admin: #{admin_email}")
end

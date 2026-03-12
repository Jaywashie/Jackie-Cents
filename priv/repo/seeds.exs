# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Insurance.Repo.insert!(%Insurance.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# priv/repo/seeds.exs
#
# Run with:  mix run priv/repo/seeds.exs
#
# Creates a default admin user if one doesn't already exist.
# Change the email/password before running in production.

alias Insurance.Accounts
alias Insurance.Repo

admin_email    = System.get_env("ADMIN_EMAIL", "jackiecents@gmail.com")
admin_password = System.get_env("ADMIN_PASSWORD", "123456789012")

case Accounts.get_user_by_email(admin_email) do
  nil ->
    {:ok, user} = Accounts.register_user(%{email: admin_email, password: admin_password})
    {:ok, _}    = Accounts.promote_to_admin(user)
    IO.puts("✅ Admin user created: #{admin_email}")

  existing ->
    {:ok, _} = Accounts.promote_to_admin(existing)
    IO.puts("✅ Existing user promoted to admin: #{admin_email}")
end

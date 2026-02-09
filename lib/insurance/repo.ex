defmodule Insurance.Repo do
  use Ecto.Repo,
    otp_app: :insurance,
    adapter: Ecto.Adapters.Postgres
end

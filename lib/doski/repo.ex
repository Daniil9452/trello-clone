defmodule Doski.Repo do
  use Ecto.Repo,
    otp_app: :doski,
    adapter: Ecto.Adapters.Postgres
end

defmodule Pipesine.Repo do
  use Ecto.Repo,
    otp_app: :pipesine,
    adapter: Ecto.Adapters.Postgres
end

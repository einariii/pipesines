defmodule Pipesine.Repo.Migrations.CreateComposersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:composers) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:composers, [:email])

    create table(:composers_tokens) do
      add :composer_id, references(:composers, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:composers_tokens, [:composer_id])
    create unique_index(:composers_tokens, [:context, :token])
  end
end

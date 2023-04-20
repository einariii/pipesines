defmodule Pipesine.Repo.Migrations.CreateCompositions do
  use Ecto.Migration

  def change do
    create table(:compositions) do
      add :score, :text
      add :composer, :string

      timestamps()
    end
  end
end

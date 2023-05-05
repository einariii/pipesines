defmodule :"Elixir.Pipesine.Repo.Migrations.Add-title-to-compositions" do
  use Ecto.Migration

  def change do
    alter table(:compositions) do
      add :title, :string
      add :composer_id, references(:composers, on_delete: :delete_all), null: false
    end
  end
end

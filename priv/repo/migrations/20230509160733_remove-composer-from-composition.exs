defmodule :"Elixir.Pipesine.Repo.Migrations.Remove-composer-from-composition" do
  use Ecto.Migration

  def change do
    alter table(:compositions) do
      remove :composer, :string
    end
  end
end

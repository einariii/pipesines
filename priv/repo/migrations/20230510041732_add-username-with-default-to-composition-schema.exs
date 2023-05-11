defmodule :"Elixir.Pipesine.Repo.Migrations.Add-username-with-default-to-composition-schema" do
  use Ecto.Migration

  def change do
    alter table(:compositions) do
      add :username, :string, default: "BEAMblaster"
    end
  end
end

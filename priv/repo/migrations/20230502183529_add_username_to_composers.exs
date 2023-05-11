defmodule Pipesine.Repo.Migrations.AddUsernameToComposers do
  use Ecto.Migration

  def change do
    alter table(:composers) do
      add :username, :string
      add :introduction, :string
    end
  end
end

defmodule Pipesine.Sound.Composition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "compositions" do
    field :score, :string
    field :title, :string
    field :username, :string, default: "BEAMblaster"
    belongs_to(:composer, Pipesine.Composers.Composer)

    timestamps()
  end

  @doc false
  def changeset(composition, attrs) do
    composition
    |> cast(attrs, [:score, :title, :composer_id, :username])
    # |> put_assoc(:composer, composer)
    |> validate_required([:score, :composer_id, :username])
    |> foreign_key_constraint(:composer_id)
  end
end

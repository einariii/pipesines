defmodule Pipesine.Sound.Composition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "compositions" do
    field :score, :string
    field :title, :string
    belongs_to(:composer, Pipesine.Composers.Composer)

    timestamps()
  end

  @doc false
  def changeset(composition, attrs, composers \\ []) do
    composition
    |> cast(attrs, [:score, :title, :composer_id])
    |> put_assoc(:composers, composers)
    |> validate_required([:score, :composer_id])
    |> foreign_key_constraint(:composer_id)
  end
end

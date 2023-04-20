defmodule Pipesine.Sound.Composition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "compositions" do
    field :composer, :string
    field :score, :string

    timestamps()
  end

  @doc false
  def changeset(composition, attrs) do
    composition
    |> cast(attrs, [:score, :composer])
    |> validate_required([:score, :composer])
  end
end

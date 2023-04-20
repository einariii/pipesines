defmodule Pipesine.SoundFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pipesine.Sound` context.
  """

  @doc """
  Generate a composition.
  """
  def composition_fixture(attrs \\ %{}) do
    {:ok, composition} =
      attrs
      |> Enum.into(%{
        composer: "some composer",
        score: "some score"
      })
      |> Pipesine.Sound.create_composition()

    composition
  end
end

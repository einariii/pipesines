defmodule Pipesine.Sound do
  @moduledoc """
  The Sound context.
  """

  import Ecto.Query, warn: false
  alias Pipesine.Repo

  alias Pipesine.Sound.Composition

  @doc """
  Returns the list of compositions.

  ## Examples

      iex> list_compositions()
      [%Composition{}, ...]

  """
  def list_compositions do
    Repo.all(Composition)
  end

  @doc """
  Gets a single composition.

  Raises `Ecto.NoResultsError` if the Composition does not exist.

  ## Examples

      iex> get_composition!(123)
      %Composition{}

      iex> get_composition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_composition!(id), do: Repo.get!(Composition, id)

  @doc """
  Creates a composition.

  ## Examples

      iex> create_composition(%{field: value})
      {:ok, %Composition{}}

      iex> create_composition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_composition(attrs \\ %{}) do
    %Composition{}
    |> Composition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a composition.

  ## Examples

      iex> update_composition(composition, %{field: new_value})
      {:ok, %Composition{}}

      iex> update_composition(composition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_composition(%Composition{} = composition, attrs) do
    composition
    |> Composition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a composition.

  ## Examples

      iex> delete_composition(composition)
      {:ok, %Composition{}}

      iex> delete_composition(composition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_composition(%Composition{} = composition) do
    Repo.delete(composition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking composition changes.

  ## Examples

      iex> change_composition(composition)
      %Ecto.Changeset{data: %Composition{}}

  """
  def change_composition(%Composition{} = composition, attrs \\ %{}) do
    Composition.changeset(composition, attrs)
  end
end

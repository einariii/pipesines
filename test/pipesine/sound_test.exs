defmodule Pipesine.SoundTest do
  use Pipesine.DataCase
  import Pipesine.ComposersFixtures
  alias Pipesine.Sound

  describe "compositions" do
    alias Pipesine.Sound.Composition

    import Pipesine.SoundFixtures

    @invalid_attrs %{composer: nil, score: nil}

    test "list_compositions/0 returns all compositions" do
      composition = composition_fixture()
      assert Sound.list_compositions() == [composition]
    end

    test "get_composition!/1 returns the composition with given id" do
      composition = composition_fixture()
      assert Sound.get_composition!(composition.id) == composition
    end

    test "create_composition/1 with valid data creates a composition" do
      composer = composer_fixture()

      valid_attrs = %{composer_id: composer.id, score: "some score"}

      assert {:ok, %Composition{} = composition} = Sound.create_composition(valid_attrs)
      assert Repo.preload(composition, :composer).composer == composer
      assert composition.score == "some score"
    end

    test "create_composition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sound.create_composition(@invalid_attrs)
    end

    test "update_composition/2 with valid data updates the composition" do
      composition = composition_fixture()
      update_attrs = %{composer: "some updated composer", score: "some updated score"}

      assert {:ok, %Composition{} = composition} = Sound.update_composition(composition, update_attrs)
      assert composition.composer == "some updated composer"
      assert composition.score == "some updated score"
    end

    test "update_composition/2 with invalid data returns error changeset" do
      composition = composition_fixture()
      assert {:error, %Ecto.Changeset{}} = Sound.update_composition(composition, @invalid_attrs)
      assert composition == Sound.get_composition!(composition.id)
    end

    test "delete_composition/1 deletes the composition" do
      composition = composition_fixture()
      assert {:ok, %Composition{}} = Sound.delete_composition(composition)
      assert_raise Ecto.NoResultsError, fn -> Sound.get_composition!(composition.id) end
    end

    test "change_composition/1 returns a composition changeset" do
      composition = composition_fixture()
      assert %Ecto.Changeset{} = Sound.change_composition(composition)
    end
  end
end

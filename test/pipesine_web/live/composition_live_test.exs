defmodule PipesineWeb.CompositionLiveTest do
  use PipesineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pipesine.SoundFixtures

  @create_attrs %{composer: "some composer", score: "some score"}
  @update_attrs %{composer: "some updated composer", score: "some updated score"}
  @invalid_attrs %{composer: nil, score: nil}

  defp create_composition(_) do
    composition = composition_fixture()
    %{composition: composition}
  end

  describe "Index" do
    setup [:create_composition]

    test "lists all compositions", %{conn: conn, composition: composition} do
      {:ok, _index_live, html} = live(conn, Routes.composition_index_path(conn, :index))

      assert html =~ "Listing Compositions"
      assert html =~ composition.composer
    end

    test "saves new composition", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.composition_index_path(conn, :index))

      assert index_live |> element("a", "New Composition") |> render_click() =~
               "New Composition"

      assert_patch(index_live, Routes.composition_index_path(conn, :new))

      assert index_live
             |> form("#composition-form", composition: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#composition-form", composition: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.composition_index_path(conn, :index))

      assert html =~ "Composition created successfully"
      assert html =~ "some composer"
    end

    test "updates composition in listing", %{conn: conn, composition: composition} do
      {:ok, index_live, _html} = live(conn, Routes.composition_index_path(conn, :index))

      assert index_live |> element("#composition-#{composition.id} a", "Edit") |> render_click() =~
               "Edit Composition"

      assert_patch(index_live, Routes.composition_index_path(conn, :edit, composition))

      assert index_live
             |> form("#composition-form", composition: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#composition-form", composition: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.composition_index_path(conn, :index))

      assert html =~ "Composition updated successfully"
      assert html =~ "some updated composer"
    end

    test "deletes composition in listing", %{conn: conn, composition: composition} do
      {:ok, index_live, _html} = live(conn, Routes.composition_index_path(conn, :index))

      assert index_live |> element("#composition-#{composition.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#composition-#{composition.id}")
    end
  end

  describe "Show" do
    setup [:create_composition]

    test "displays composition", %{conn: conn, composition: composition} do
      {:ok, _show_live, html} = live(conn, Routes.composition_show_path(conn, :show, composition))

      assert html =~ "Show Composition"
      assert html =~ composition.composer
    end

    test "updates composition within modal", %{conn: conn, composition: composition} do
      {:ok, show_live, _html} = live(conn, Routes.composition_show_path(conn, :show, composition))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Composition"

      assert_patch(show_live, Routes.composition_show_path(conn, :edit, composition))

      assert show_live
             |> form("#composition-form", composition: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#composition-form", composition: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.composition_show_path(conn, :show, composition))

      assert html =~ "Composition updated successfully"
      assert html =~ "some updated composer"
    end
  end
end

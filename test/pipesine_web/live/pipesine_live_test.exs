defmodule PipesineWeb.PipesineLiveTest do
  use PipesineWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Pipesine.SoundFixtures

  # @create_attrs %{composer: "some composer", score: "some score"}
  # @update_attrs %{composer: "some updated composer", score: "some updated score"}
  # @invalid_attrs %{composer: nil, score: nil}



  describe "Main View" do
    # setup [:create_composition]

    test "loads unmounted page", %{conn: conn} do
      # html = get(conn, "/")
      # assert html =~ "code to music to"
    end

    test "loads mounted page", %{conn: conn} do
      {:ok, _live, html} = live(conn, Routes.pipesine_path(conn, :index))
      assert html =~ "code to music to"
    end

    test "background renders correctly", %{conn: conn} do
      {:ok, _live, html} = live(conn, Routes.pipesine_path(conn, :index))
      IO.inspect(html)
      assert html =~ "/images/pipesine_wavy_farsi.png"
      assert html =~ "background"
    end
  end

  # describe "Show" do
  #   setup [:create_composition]

  #   test "displays composition", %{conn: conn, composition: composition} do
  #     {:ok, _show_live, html} = live(conn, Routes.composition_show_path(conn, :show, composition))

  #     assert html =~ "Show Composition"
  #     assert html =~ composition.composer
  #   end

  #   test "updates composition within modal", %{conn: conn, composition: composition} do
  #     {:ok, show_live, _html} = live(conn, Routes.composition_show_path(conn, :show, composition))

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Composition"

  #     assert_patch(show_live, Routes.composition_show_path(conn, :edit, composition))

  #     assert show_live
  #            |> form("#composition-form", composition: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       show_live
  #       |> form("#composition-form", composition: @update_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, Routes.composition_show_path(conn, :show, composition))

  #     assert html =~ "Composition updated successfully"
  #     assert html =~ "some updated composer"
  #   end
  # end
end

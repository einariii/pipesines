defmodule PipesineWeb.ComposerConfirmationControllerTest do
  use PipesineWeb.ConnCase, async: true

  alias Pipesine.Composers
  alias Pipesine.Repo
  import Pipesine.ComposersFixtures

  setup do
    %{composer: composer_fixture()}
  end

  describe "GET /composers/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.composer_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /composers/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, composer: composer} do
      conn =
        post(conn, Routes.composer_confirmation_path(conn, :create), %{
          "composer" => %{"email" => composer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Composers.ComposerToken, composer_id: composer.id).context == "confirm"
    end

    test "does not send confirmation token if Composer is confirmed", %{
      conn: conn,
      composer: composer
    } do
      Repo.update!(Composers.Composer.confirm_changeset(composer))

      conn =
        post(conn, Routes.composer_confirmation_path(conn, :create), %{
          "composer" => %{"email" => composer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Composers.ComposerToken, composer_id: composer.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.composer_confirmation_path(conn, :create), %{
          "composer" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Composers.ComposerToken) == []
    end
  end

  describe "GET /composers/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.composer_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.composer_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /composers/confirm/:token" do
    test "confirms the given token once", %{conn: conn, composer: composer} do
      token =
        extract_composer_token(fn url ->
          Composers.deliver_composer_confirmation_instructions(composer, url)
        end)

      conn = post(conn, Routes.composer_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Composer confirmed successfully"
      assert Composers.get_composer!(composer.id).confirmed_at
      refute get_session(conn, :composer_token)
      assert Repo.all(Composers.ComposerToken) == []

      # When not logged in
      conn = post(conn, Routes.composer_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Composer confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_composer(composer)
        |> post(Routes.composer_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, composer: composer} do
      conn = post(conn, Routes.composer_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Composer confirmation link is invalid or it has expired"
      refute Composers.get_composer!(composer.id).confirmed_at
    end
  end
end

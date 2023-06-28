defmodule PipesineWeb.ComposerSessionControllerTest do
  use PipesineWeb.ConnCase, async: true

  import Pipesine.ComposersFixtures

  setup do
    %{composer: composer_fixture()}
  end

  describe "GET /composers/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.composer_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, composer: composer} do
      conn = conn |> log_in_composer(composer) |> get(Routes.composer_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /composers/log_in" do
    test "logs the composer in", %{conn: conn, composer: composer} do
      conn =
        post(conn, Routes.composer_session_path(conn, :create), %{
          "composer" => %{"email" => composer.email, "password" => valid_composer_password()}
        })

      assert get_session(conn, :composer_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ composer.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the composer in with remember me", %{conn: conn, composer: composer} do
      conn =
        post(conn, Routes.composer_session_path(conn, :create), %{
          "composer" => %{
            "email" => composer.email,
            "password" => valid_composer_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_pipesine_web_composer_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the composer in with return to", %{conn: conn, composer: composer} do
      conn =
        conn
        |> init_test_session(composer_return_to: "/foo/bar")
        |> post(Routes.composer_session_path(conn, :create), %{
          "composer" => %{
            "email" => composer.email,
            "password" => valid_composer_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, composer: composer} do
      conn =
        post(conn, Routes.composer_session_path(conn, :create), %{
          "composer" => %{"email" => composer.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /composers/log_out" do
    test "logs the composer out", %{conn: conn, composer: composer} do
      conn =
        conn |> log_in_composer(composer) |> delete(Routes.composer_session_path(conn, :delete))

      assert redirected_to(conn) == "/"
      refute get_session(conn, :composer_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the composer is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.composer_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :composer_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end

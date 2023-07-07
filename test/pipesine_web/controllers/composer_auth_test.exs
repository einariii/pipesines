defmodule PipesineWeb.ComposerAuthTest do
  use PipesineWeb.ConnCase, async: true

  alias Pipesine.Composers
  alias PipesineWeb.ComposerAuth
  import Pipesine.ComposersFixtures

  @remember_me_cookie "_pipesine_web_composer_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, PipesineWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{composer: composer_fixture(), conn: conn}
  end

  describe "log_in_composer/3" do
    test "stores the composer token in the session", %{conn: conn, composer: composer} do
      conn = ComposerAuth.log_in_composer(conn, composer)
      assert token = get_session(conn, :composer_token)

      assert get_session(conn, :live_socket_id) ==
               "composers_sessions:#{Base.url_encode64(token)}"

      assert redirected_to(conn) == "/"
      assert Composers.get_composer_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, composer: composer} do
      conn =
        conn |> put_session(:to_be_removed, "value") |> ComposerAuth.log_in_composer(composer)

      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, composer: composer} do
      conn =
        conn
        |> put_session(:composer_return_to, "/hello")
        |> ComposerAuth.log_in_composer(composer)

      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, composer: composer} do
      conn =
        conn
        |> fetch_cookies()
        |> ComposerAuth.log_in_composer(composer, %{"remember_me" => "true"})

      assert get_session(conn, :composer_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :composer_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_composer/1" do
    test "erases session and cookies", %{conn: conn, composer: composer} do
      composer_token = Composers.generate_composer_session_token(composer)

      conn =
        conn
        |> put_session(:composer_token, composer_token)
        |> put_req_cookie(@remember_me_cookie, composer_token)
        |> fetch_cookies()
        |> ComposerAuth.log_out_composer()

      refute get_session(conn, :composer_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Composers.get_composer_by_session_token(composer_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "composers_sessions:abcdef-token"
      PipesineWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> ComposerAuth.log_out_composer()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if composer is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> ComposerAuth.log_out_composer()
      refute get_session(conn, :composer_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_composer/2" do
    test "authenticates composer from session", %{conn: conn, composer: composer} do
      composer_token = Composers.generate_composer_session_token(composer)

      conn =
        conn
        |> put_session(:composer_token, composer_token)
        |> ComposerAuth.fetch_current_composer([])

      assert conn.assigns.current_composer.id == composer.id
    end

    test "authenticates composer from cookies", %{conn: conn, composer: composer} do
      logged_in_conn =
        conn
        |> fetch_cookies()
        |> ComposerAuth.log_in_composer(composer, %{"remember_me" => "true"})

      composer_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> ComposerAuth.fetch_current_composer([])

      assert get_session(conn, :composer_token) == composer_token
      assert conn.assigns.current_composer.id == composer.id
    end

    test "does not authenticate if data is missing", %{conn: conn, composer: composer} do
      _ = Composers.generate_composer_session_token(composer)
      conn = ComposerAuth.fetch_current_composer(conn, [])
      refute get_session(conn, :composer_token)
      refute conn.assigns.current_composer
    end
  end

  describe "redirect_if_composer_is_authenticated/2" do
    test "redirects if composer is authenticated", %{conn: conn, composer: composer} do
      conn =
        conn
        |> assign(:current_composer, composer)
        |> ComposerAuth.redirect_if_composer_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if composer is not authenticated", %{conn: conn} do
      conn = ComposerAuth.redirect_if_composer_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_composer/2" do
    test "redirects if composer is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> ComposerAuth.require_authenticated_composer([])
      assert conn.halted
      assert redirected_to(conn) == Routes.composer_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> ComposerAuth.require_authenticated_composer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :composer_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> ComposerAuth.require_authenticated_composer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :composer_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> ComposerAuth.require_authenticated_composer([])

      assert halted_conn.halted
      refute get_session(halted_conn, :composer_return_to)
    end

    test "does not redirect if composer is authenticated", %{conn: conn, composer: composer} do
      conn =
        conn
        |> assign(:current_composer, composer)
        |> ComposerAuth.require_authenticated_composer([])

      refute conn.halted
      refute conn.status
    end
  end
end

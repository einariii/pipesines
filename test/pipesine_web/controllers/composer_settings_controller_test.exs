defmodule PipesineWeb.ComposerSettingsControllerTest do
  use PipesineWeb.ConnCase, async: true

  alias Pipesine.Composers
  import Pipesine.ComposersFixtures

  setup :register_and_log_in_composer

  describe "GET /composers/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.composer_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if composer is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.composer_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.composer_session_path(conn, :new)
    end
  end

  describe "PUT /composers/settings (change password form)" do
    test "updates the composer password and resets tokens", %{conn: conn, composer: composer} do
      new_password_conn =
        put(conn, Routes.composer_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_composer_password(),
          "composer" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.composer_settings_path(conn, :edit)
      assert get_session(new_password_conn, :composer_token) != get_session(conn, :composer_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Composers.get_composer_by_email_and_password(composer.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.composer_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "composer" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :composer_token) == get_session(conn, :composer_token)
    end
  end

  describe "PUT /composers/settings (change email form)" do
    @tag :capture_log
    test "updates the composer email", %{conn: conn, composer: composer} do
      conn =
        put(conn, Routes.composer_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_composer_password(),
          "composer" => %{"email" => unique_composer_email()}
        })

      assert redirected_to(conn) == Routes.composer_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Composers.get_composer_by_email(composer.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.composer_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "composer" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /composers/settings/confirm_email/:token" do
    setup %{composer: composer} do
      email = unique_composer_email()

      token =
        extract_composer_token(fn url ->
          Composers.deliver_update_email_instructions(
            %{composer | email: email},
            composer.email,
            url
          )
        end)

      %{token: token, email: email}
    end

    test "updates the composer email once", %{
      conn: conn,
      composer: composer,
      token: token,
      email: email
    } do
      conn = get(conn, Routes.composer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.composer_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Composers.get_composer_by_email(composer.email)
      assert Composers.get_composer_by_email(email)

      conn = get(conn, Routes.composer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.composer_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, composer: composer} do
      conn = get(conn, Routes.composer_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.composer_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Composers.get_composer_by_email(composer.email)
    end

    test "redirects if composer is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.composer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.composer_session_path(conn, :new)
    end
  end
end

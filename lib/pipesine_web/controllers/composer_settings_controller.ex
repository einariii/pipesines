defmodule PipesineWeb.ComposerSettingsController do
  use PipesineWeb, :controller

  alias Pipesine.Composers
  alias PipesineWeb.ComposerAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "composer" => composer_params} = params
    composer = conn.assigns.current_composer

    case Composers.apply_composer_email(composer, password, composer_params) do
      {:ok, applied_composer} ->
        Composers.deliver_update_email_instructions(
          applied_composer,
          composer.email,
          &Routes.composer_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.composer_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "composer" => composer_params} = params
    composer = conn.assigns.current_composer

    case Composers.update_composer_password(composer, password, composer_params) do
      {:ok, composer} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:composer_return_to, Routes.composer_settings_path(conn, :edit))
        |> ComposerAuth.log_in_composer(composer)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Composers.update_composer_email(conn.assigns.current_composer, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.composer_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.composer_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    composer = conn.assigns.current_composer

    conn
    |> assign(:email_changeset, Composers.change_composer_email(composer))
    |> assign(:password_changeset, Composers.change_composer_password(composer))
  end
end

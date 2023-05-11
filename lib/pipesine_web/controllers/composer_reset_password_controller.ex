defmodule PipesineWeb.ComposerResetPasswordController do
  use PipesineWeb, :controller

  alias Pipesine.Composers

  plug :get_composer_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"composer" => %{"email" => email}}) do
    if composer = Composers.get_composer_by_email(email) do
      Composers.deliver_composer_reset_password_instructions(
        composer,
        &Routes.composer_reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Composers.change_composer_password(conn.assigns.composer))
  end

  # Do not log in the composer after reset password to avoid a
  # leaked token giving the composer access to the account.
  def update(conn, %{"composer" => composer_params}) do
    case Composers.reset_composer_password(conn.assigns.composer, composer_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.composer_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_composer_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if composer = Composers.get_composer_by_reset_password_token(token) do
      conn |> assign(:composer, composer) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end

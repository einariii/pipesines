defmodule PipesineWeb.ComposerConfirmationController do
  use PipesineWeb, :controller

  alias Pipesine.Composers

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"composer" => %{"email" => email}}) do
    if composer = Composers.get_composer_by_email(email) do
      Composers.deliver_composer_confirmation_instructions(
        composer,
        &Routes.composer_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the composer after confirmation to avoid a
  # leaked token giving the composer access to the account.
  def update(conn, %{"token" => token}) do
    case Composers.confirm_composer(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Composer confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current composer and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the composer themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_composer: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Composer confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end

defmodule PipesineWeb.ComposerSessionController do
  use PipesineWeb, :controller

  alias Pipesine.Composers
  alias PipesineWeb.ComposerAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"composer" => composer_params}) do
    %{"email" => email, "password" => password} = composer_params

    if composer = Composers.get_composer_by_email_and_password(email, password) do
      ComposerAuth.log_in_composer(conn, composer, composer_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> ComposerAuth.log_out_composer()
  end
end

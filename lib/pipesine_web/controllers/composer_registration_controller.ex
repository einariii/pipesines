defmodule PipesineWeb.ComposerRegistrationController do
  use PipesineWeb, :controller

  alias Pipesine.Composers
  alias Pipesine.Composers.Composer
  alias PipesineWeb.ComposerAuth

  def new(conn, _params) do
    changeset = Composers.change_composer_registration(%Composer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"composer" => composer_params}) do
    case Composers.register_composer(composer_params) do
      {:ok, composer} ->
        {:ok, _} =
          Composers.deliver_composer_confirmation_instructions(
            composer,
            &Routes.composer_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Composer created successfully.")
        |> ComposerAuth.log_in_composer(composer)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end

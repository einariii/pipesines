defmodule PipesineWeb.CompositionLive.FormComponent do
  use PipesineWeb, :live_component

  alias Pipesine.Sound

  @impl true
  def update(%{composition: composition} = assigns, socket) do
    changeset = Sound.change_composition(composition)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"composition" => composition_params}, socket) do
    changeset =
      socket.assigns.composition
      |> Sound.change_composition(composition_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"composition" => composition_params}, socket) do
    save_composition(socket, socket.assigns.action, composition_params)
  end

  defp save_composition(socket, :edit, composition_params) do
    case Sound.update_composition(socket.assigns.composition, composition_params) do
      {:ok, _composition} ->
        {:noreply,
         socket
         |> put_flash(:info, "Composition updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_composition(socket, :new, composition_params) do
    case Sound.create_composition(composition_params) do
      {:ok, _composition} ->
        {:noreply,
         socket
         |> put_flash(:info, "Composition created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

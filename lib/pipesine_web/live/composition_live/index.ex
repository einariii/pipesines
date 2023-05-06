defmodule PipesineWeb.CompositionLive.Index do
  use PipesineWeb, :live_view

  alias Pipesine.Sound
  alias Pipesine.Sound.Composition

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:compositions)
    |> assign(:composers)
    |> assign(list_compositions())

    {:ok, socket}
    # {:ok, assign(socket, :compositions, list_compositions())}

  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Composition")
    |> assign(:composition, Sound.get_composition!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Composition")
    |> assign(:composition, %Composition{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Compositions")
    |> assign(:composition, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    composition = Sound.get_composition!(id)
    {:ok, _} = Sound.delete_composition(composition)

    {:noreply, assign(socket, :compositions, list_compositions())}
  end

  defp list_compositions do
    Sound.list_compositions()
  end
end

defmodule PipesineWeb.CompositionLive.Index do
  use PipesineWeb, :live_view

  alias Pipesine.Sound
  alias Pipesine.Sound.Composition
  alias Pipesine.Composers

  @impl true
  def mount(_params, _session, socket) do
    # socket
    # |> assign(:compositions, Sound.list_compositions())
    # |> assign(:composers, Composers.list_composers())
    # {:ok, socket}
    if connected?(socket), do: Sound.subscribe()
    {:ok, assign(socket, :compositions, Sound.list_compositions())}
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

  def handle_info({:composition_created, composition}, socket) do
    {:noreply, update(socket, :compositions, fn compositions -> [composition | compositions] end)}
  end
  defp list_compositions do
    Sound.list_compositions()
  end
end

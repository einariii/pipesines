defmodule PipesineWeb.CompositionLive.Show do
  use PipesineWeb, :live_view

  alias Pipesine.Sound

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:composition, Sound.get_composition!(id))}
  end

  defp page_title(:show), do: "Show Composition"
  defp page_title(:edit), do: "Edit Composition"
end

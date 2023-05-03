defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view

  def mount(_params, _session, socket) do
    # {:ok, assign(socket, :connected, connected?(socket))}
    {:ok, assign(socket, display_modal: false, connected: connected?(socket))}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <div id="container" style="width: 1200px; height: 600px; border: 9px solid black" phx-hook="Editor"></div>
      <button phx-click="save">SAVE</button>
    """
  end

  def handle_event("perform", params, socket) do
    IO.inspect(params, label: "PARAMS")
    {:noreply, push_event(socket, "update_score", Pipesine.Sound.compose_composition(params["score"]))}
  end

  def handle_event("save", params, socket) do
    # IO.inspect(socket.assigns.composer_id, label: "COMPOSERID")
    # if socket.assigns.composer_id do
    #   Pipesine.Sound.create_composition(params["score"])
    #   # Pipesine.Sound.compose_composition(%Composition{
    #   #   score: socket.assigns.params["score"],
    #   #   composer_id: socket.assigns.composer_id
    #   # })
    # end
    # {:noreply, socket}
  end

  # def handle_event("toggle_modal", params, socket) do
  #   {:noreply, assign(socket, :display_modal, !socket.assigns.display_modal)}
  # end
end

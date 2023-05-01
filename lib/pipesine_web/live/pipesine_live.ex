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
    """
  end

  def handle_event("perform", params, socket) do
    # IO.inspect(params)
    {:noreply, push_event(socket, "update_score", Pipesine.Sound.compose_composition(params["score"]))}
  end

  # def handle_event("toggle_modal", params, socket) do
  #   {:noreply, assign(socket, :display_modal, !socket.assigns.display_modal)}
  # end
end

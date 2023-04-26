defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :connected, connected?(socket))}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <div id="container" class="background" style="width: 1200px; height: 600px; border: 9px solid black" phx-hook="Editor"></div>
    """
  end

  def handle_event("perform", params, socket) do
    IO.inspect(params)
    {:noreply, push_event(socket, "update_score", Pipesine.Sound.compose_composition(params["score"]))}
  end
end

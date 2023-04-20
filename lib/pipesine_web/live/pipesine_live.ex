defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id="container" phx-update="ignore" class="background" style="width: 1200px; height: 600px; border: 8px solid black"></div>
    <button id="click-hook" phx-hook="ClickHook">PERFORM</button>
    <div style="">
      <.form let={f} for={:perform_form} phx-submit="perform">
        <%= text_input f, :perform, id: "basic-play", phx_hook: "BasicPlay" %>
      </.form>
    </div>
    """
  end

  # def handle_event("ping", _params, socket) do
  #   {:noreply, push_event(socket, "pong", %{})}
  # end

  # def handle_event("perform", %{"perform_form" => %{"perform" => perform}}, socket) do
  #   {:noreply, push_event(socket, :perform, params)}
  # end

  def handle_event("perform", params, socket) do
    metascore = params["perform_form"]
    score = metascore["perform"]

    scanned_score = Regex.scan(~r/\w/, score)
    flat_scan = List.flatten(scanned_score)

    bits = abs(Enum.count(flat_scan) - 16)
    crusher =
      cond do
        bits <= 16 && bits >=4 -> bits
        true -> 16
      end

    chebs = List.last(flat_scan)
    # note2 = "F3"

    IO.inspect(flat_scan)
    IO.inspect(chebs)

    {:noreply, push_event(socket, "update_score", %{note1: ["Eb3", "Gb3", "C4"], note2: "F3", crusher: crusher, delayTime: 0.4, delayFeedback: 0.6})}
    # {:noreply, assign(socket, :score, params)}
  end

end

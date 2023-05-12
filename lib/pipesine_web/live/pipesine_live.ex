defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view
  import Plug.Conn
  import Pipesine.Composers

  def mount(params, session, socket) do
    composer_id =
      if session["composer_token"],
        do:
          get_composer_by_session_token(session["composer_token"]).id
          |> IO.inspect(label: "COMPOSERID")

    composer_username =
      if session["composer_token"],
        do:
          get_composer_by_session_token(session["composer_token"]).username
          |> IO.inspect(label: "USERNA<ME")

    composer_email =
      if session["composer_token"],
        do:
          get_composer_by_session_token(session["composer_token"]).email
          |> IO.inspect(label: "EMAIL")

    score = params["score"]

    {
      :ok,
      socket
      |> assign(display_modal: false)
      |> assign(score: score)
      |> assign(composer_id: composer_id)
      # |> assign(composer_username: composer_username)
      # |> assign(composer_email: composer_email)
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
    <button class="krub">AST version</button>
    <button class="krub">REGEX version</button>
    <div id="container" class="filtered" style="width: 1200px; height: 600px; border: 9px solid black" phx-hook="Editor"></div>
      <button class="krub" phx-click="save" style="margin-top: 8px">save composition</button>
      </div>
    <%= if @live_action == :about do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.AboutComponent} id={@display_modal} />
      </.modal>
    <% end %>
    <%= if @live_action == :manifesto do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.ManifestoComponent} id={@display_modal} />
      </.modal>
    <% end %>
    <%= if @live_action == :label do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.LabelComponent} id={@display_modal} />
      </.modal>
    <% end %>
    """
  end

  # <.modal>
  #         <.live_component module={PipesineWeb.CompositionLive.InstructionsComponent} id={@composer_id} />
  #       </.modal>
  # <span><%= live_patch "New Message", to: Routes.composition_index_path(@socket, :new) %></span>

  def handle_event("perform", params, socket) do
    score = Pipesine.Sound.compose_composition(params["score"])

    {:noreply,
     socket
     |> assign(score: params["score"])
     |> push_event("update_score", score)}
  end

  def handle_event("save", _params, socket) do
    if socket.assigns.composer_id do
      Pipesine.Sound.create_composition(%{
        score: socket.assigns.score,
        composer_id: socket.assigns.composer_id
        # composer_username: socket.assigns.composer_username,
        # composer_email: socket.assigns.composer_email
      })
    else
      put_flash(socket, :error, "You must be logged in to save (also you must evaluate before attempting to save)")
    end
    {:noreply, socket}
  end

  # def handle_event("toggle_modal", params, socket) do
  #   {:noreply, assign(socket, :display_modal, !socket.assigns.display_modal)}
  # end
end

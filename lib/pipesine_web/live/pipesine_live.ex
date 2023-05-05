defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view
  import Pipesine.Composers

  def mount(params, session, socket) do
    # IO.inspect(params["score"], label: "PARAMSSINITAL")
    # {:ok, assign(socket, :connected, connected?(socket))}
    # {:ok, assign(socket, display_modal: false, connected: connected?(socket))}
    # composer_id = if session["composer_token"], do: get_composer_by_session_token(session["composer_token"]).id
    # composer_username = if session["composer_token"], do: get_composer_by_session_token(session["composer_token"]).username
    # {:ok, assign(socket, score: params["score"], composer_id: composer_id, composer_username: composer_username)}

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

    score = params["score"]

    # {:ok, assign(socket, score: score, composer_id: composer_id, composer_username: composer_username)}

    # socket
    # |> assign(score: score)
    # |> assign(composer_id: composer_id)
    # |> assign(composer_username: composer_username)
    # |> IO.inspect(label: "SOKCKCKCETTTT")

    {
      :ok,
      (socket
      |> assign(score: score)
      |> assign(composer_id: composer_id)
      |> assign(composer_username: composer_username)
      )
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
    <div id="container" style="width: 1200px; height: 600px; border: 9px solid black" phx-hook="Editor"></div>
    <button phx-click="save">SAVE COMPOSITION</button>
    </div>
    """
  end
  
  def handle_event("perform", params, socket) do
    score = Pipesine.Sound.compose_composition(params["score"])

    {:noreply,
    socket
    |> assign(score: params["score"])
    |> push_event("update_score", score)
  }
  end

  def handle_event("save", params, socket) do
    if socket.assigns.composer_id do
      Pipesine.Sound.create_composition(%{
        score: socket.assigns.score,
        composer_id: socket.assigns.composer_id,
        composer_username: socket.assigns.composer_username
      })
      else
        IO.inspect("FECK WWHY DAMGIT")
    end
    {:noreply, socket}
  end

  # def handle_event("toggle_modal", params, socket) do
  #   {:noreply, assign(socket, :display_modal, !socket.assigns.display_modal)}
  # end
end

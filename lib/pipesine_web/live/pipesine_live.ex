defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view
  import Pipesine.Composers

  def mount(params, _session, socket) do
    # composer_id =
    #   if session["composer_token"],
    #     do:
    #       get_composer_by_session_token(session["composer_token"]).id
    # |> IO.inspect(label: "COMPOSERID")

    # composer_username =
    #   if session["composer_token"],
    #     do:
    #       get_composer_by_session_token(session["composer_token"]).username
    #       |> IO.inspect(label: "USERNA<ME")
    #
    # composer_email =
    #   if session["composer_token"],
    #     do:
    #       get_composer_by_session_token(session["composer_token"]).email
    #       |> IO.inspect(label: "EMAIL")

    score = params["score"]

    {
      :ok,
      socket
      |> assign(display_modal: false)
      |> assign(score: score)
      # |> assign(composer_id: composer_id)
      # |> assign(composer_username: composer_username)
      # |> assign(composer_email: composer_email)
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="text-editor">
      <div class="fake-buttons">
        <div class="tooltip versions"><button class="krub" disabled>REGEX mode</button>
          <span class="tooltiptext">current default<br>PCRE regular expressions!</span>
        </div>
        <div class="tooltip versions"><button class="krub" disabled>AST mode</button>
          <span class="tooltiptext">future implementation<br>ABSTRACT SYNTAX TREE!</span>
        </div>
        <div class="tooltip versions"><button class="krub" disabled>ML mode</button>
          <span class="tooltiptext">future implementation<br>MACHINE LEARNING!</span>
        </div>
      </div>

      <div id="container" class="filtered" style="width: 1200px; height: 650px; border: 9px solid black" phx-hook="Editor"></div>

      <div class="fake-buttons">
        <div class="tooltip versions"><button class="krub" style="margin-top: 8px" disabled>play code</button>
          <span class="tooltiptext">TO HEAR YOUR ELIXIR<br>type alt+p (opt+p on mac)<br>in the editor!</span>
        </div>
        <div class="tooltip versions"><button class="krub" style="margin-top: 8px" disabled>it sounds glitchy</button>
          <span class="tooltiptext">LET IT GLITCH<br>
          <br>
          ...or refresh the page</span>
        </div>
        <div class="tooltip versions"><button class="krub" style="margin-top: 8px" disabled>scales</button>
          <span class="tooltiptext">set scale on the first line.
          options = 22_edo, bohlen_pierce, sa_murcchana, tonality_diamond, just_intonation, pentatonic.
          default = superpyth</span>
        </div>
      </div>
    </div>

    <%= if @live_action == :about do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.AboutComponent} id={@display_modal} />
      </.modal>
    <% end %>
    <%= if @live_action == :ethos do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.EthosComponent} id={@display_modal} />
      </.modal>
    <% end %>
    <%= if @live_action == :label do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.LabelComponent} id={@display_modal} />
      </.modal>
    <% end %>
    <%= if @live_action == :technique do %>
      <.modal>
        <.live_component module={PipesineWeb.PipesineLive.TechniqueComponent} id={@display_modal} />
      </.modal>
    <% end %>
    """
  end

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
      put_flash(
        socket,
        :error,
        "You must be logged in to save (you must also evaluate before attempting to save!)"
      )
    end

    {:noreply, socket}
  end
end

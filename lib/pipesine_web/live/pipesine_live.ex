defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view
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
    <div class="tooltip versions"><button class="krub">REGEX mode</button>
      <span class="tooltiptext">current_default =<br>PCRE regular expressions!</span>
    </div>
    <div class="tooltip versions"><button class="krub">AST mode</button>
      <span class="tooltiptext">future_implement =<br>ABSTRACT SYNTAX TREE!</span>
    </div>
    <div class="tooltip versions"><button class="krub">ML mode</button>
      <span class="tooltiptext">future_implement =<br>MACHINE LEARNING!</span>
      </div>
    <div id="container" class="filtered" style="width: 1200px; height: 650px; border: 9px solid black" phx-hook="Editor"></div>
      <div class="tooltip versions"><button class="krub" phx-click="perform" style="margin-top: 8px">play code</button>
        <span class="tooltiptext">TO HEAR YOUR ELIXIR<br>type alt+p (option+p on mac) in the editor!</span>
      </div>
      <div class="tooltip versions"><button class="krub" phx-click="save" style="margin-top: 8px">save composition</button>
        <span class="tooltiptext"><i>registered users click here to persist your code in the community database!</i></span>
      </div>
      <div class="tooltip versions"><button class="krub" phx-click="perform" style="margin-top: 8px">it sounds glitchy :(</button>
        <span class="tooltiptext">LET IT GLITCH<br>
        to glitch is to take<br>
        the <i>tempreature</i><br>
        (temporary feature/<br>
        temporary creature)<br>
        of the system </span>
      </div>
    </div>
    <div>

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
      put_flash(socket, :error, "You must be logged in to save (you must also evaluate before attempting to save!)")
    end
    {:noreply, socket}
  end
end

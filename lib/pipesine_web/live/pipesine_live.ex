defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view
  # import Pipesine.Composers

  def mount(params, session, socket) do
    score = params["score"]
    is_mobile = Map.get(session, "is_mobile", false)

    {
      :ok,
      socket
      |> assign(toggle_modal: nil)
      |> assign(score: score)
      |> assign(is_mobile: is_mobile)
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    IO.inspect(assigns, label: "ASSINGS IN LV")

    ~H"""
    <div class="vt323">
      <nav class="menuright">
        <button phx-click="toggle_about">:about</button>
        <button phx-click="toggle_ethos">:ethos</button>
        <button phx-click="toggle_tekne">:tekne</button>
        <button phx-click="toggle_label">:label</button>

        <%# <PipesineWeb.Components.link href="/about">:about</PipesineWeb.Components.link> %>
        <%# <PipesineWeb.Components.link href="/ethos">:ethos</PipesineWeb.Components.link> %>
        <%# <PipesineWeb.Components.link href="/technique">:technique</PipesineWeb.Components.link> %>
        <%# <PipesineWeb.Components.link href="/label">:label</PipesineWeb.Components.link> %>
        <%# <PipesineWeb.Components.link href="/compositions">:compositions</PipesineWeb.Components.link>
        <a class=""><%= render "_composer_menu.html", assigns </a> %>
      </nav>
    </div>
    <div class="text-editor">
      <div class="fake-buttons">
        <div class="tooltip versions"><button class="vt323" disabled>REGEX mode</button>
          <span class="tooltiptext">current default<br>PCRE regular expressions!</span>
        </div>
        <div class="tooltip versions"><button class="vt323" disabled>AST mode</button>
          <span class="tooltiptext">future implementation<br>ABSTRACT SYNTAX TREE!</span>
        </div>
        <div class="tooltip versions"><button class="vt323" disabled>ML mode</button>
          <span class="tooltiptext">future implementation<br>MACHINE LEARNING!</span>
        </div>
      </div>

      <div id="editor" class="filtered" style="width: 120rem; height: 60rem; border: 3px solid #000" phx-hook="Editor"></div>

      <div class="fake-buttons">
        <div class="tooltip versions"><button class="vt323" style="margin-top: 8px" disabled>play code</button>
          <span class="tooltiptext">TO HEAR YOUR ELIXIR<br>type alt+p (opt+p on mac)<br>in the editor!</span>
        </div>
        <div class="tooltip versions"><button class="vt323" style="margin-top: 8px" disabled>it sounds glitchy</button>
          <span class="tooltiptext">LET IT GLITCH<br>
          <br>
          ...or refresh the page</span>
        </div>
        <div class="tooltip versions"><button class="vt323" style="margin-top: 8px" disabled>scales</button>
          <span class="tooltiptext">set scale on the first line.<br />
          options = 22_edo, bohlen_pierce, sa_murcchana, tonality_diamond, just_intonation, pentatonic.<br />
          default = superpyth</span>
        </div>
      </div>
    </div>

      <%= if @toggle_modal == :about do %>
        <.modal>
          <.live_component
            module={PipesineWeb.PipesineLive.AboutComponent}
            id="about_modal"
          />
        </.modal>
      <% end %>
    <%= if @toggle_modal == :ethos do %>
      <.modal>
        <.live_component
          module={PipesineWeb.PipesineLive.EthosComponent}
          id="ethos_modal"
        />
      </.modal>
    <% end %>
    <%= if @toggle_modal == :label do %>
      <.modal>
        <.live_component
          module={PipesineWeb.PipesineLive.LabelComponent}
          id="tekne_modal"
        />
      </.modal>
    <% end %>
    <%= if @toggle_modal== :tekne do %>
      <.modal>
        <.live_component
          module={PipesineWeb.PipesineLive.TechniqueComponent}
          id="label_modal"
        />
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

  def handle_event("toggle_about", _value, socket) do
    {:noreply, assign(socket, toggle_modal: :about)}
  end

  def handle_event("toggle_ethos", _value, socket) do
    {:noreply, assign(socket, toggle_modal: :ethos)}
  end

  def handle_event("toggle_tekne", _value, socket) do
    {:noreply, assign(socket, toggle_modal: :tekne)}
  end

  def handle_event("toggle_label", _value, socket) do
    {:noreply, assign(socket, toggle_modal: :label)}
  end

  def handle_event("close_modal", _value, socket) do
    {:noreply, assign(socket, toggle_modal: nil)}
  end
end

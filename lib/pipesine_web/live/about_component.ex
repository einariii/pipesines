defmodule PipesineWeb.PipesineLive.AboutComponent do
  use PipesineWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""

      <p class="">
      <br>
      <h1>Pipesines. Elixir as musical instrument.</h1>
      Pipesines (v0.1.0) is a web app that encourages Elixir developers to explore sound through code: general programming as a specific sonic experience.

      What do <code class="coded">|></code> sound like? Which is more musical: <code class="coded">if</code>, <code class="coded">case</code>, or <code class="coded">cond</code>? Will <code class="coded">Enum.filter</code> actually filter a sound? And what about <code class="coded">Enum.reduce</code>?

      <code class="coded">assert compose(Elixir) == compose(music)</code>

      Paste existing code into the text editor, or write something from scratch. Type <code class="coded">alt+p</code> to hear how it sounds. Initially it may seem like a chaotic mess. Type <code class="coded">alt+p</code> again to pause. Adding, deleting, or refactoring may lead to more pleasant, harmonious, or musical output. Or not! What sounds "good" is a subjective judgment. What do your coder ears prefer?

      Create an account to add your code/compositions to the community database. Save an entire <code class="coded">defmodule</code>, or just one line!

      Pipesines is an open-source space where contributors are very much welcome. Future versions should improve on optimization, accessibility, and ideally, adding additional BEAM languages to the platform.

      Built using Elixir, Phoenix LiveView, Ecto, PostgresQL, and the excellent <a href="https://tonejs.github.io/">Tone.js</a>

      Inspired by GEMS by @nbw, Beats by @mtrudel, Max Mathews, Joan Miller, Laurie Spiegel, the monome community, Sonic Pi, SuperCollider, Tidal Cycles, algorave, ok all computer music programming ever, and all the sociotechnical wonders of the BEAM ecosystem.

      Special thanks to @brooklinjazz, @czrpb, @byronsalty, @IciaCarroBarallobre, @a-alhusaini, @BigSpaces, @w0rd-driven, and all my colleagues at DockYard Academy for their support and camaraderie.
      </p>

    """
  end
end

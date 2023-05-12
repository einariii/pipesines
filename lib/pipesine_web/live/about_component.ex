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
      <h1>Pipesines. Code to music to.</h1>
      Pipesines (v0.1.0) is a web app that encourages Elixir developers to explore sound through code: general programming as a specific sonic experience.

      What do |> sound like? Which is more musical: if, case, or cond? Will Enum.filter actually filter a sound? And what about Enum.reduce?

      <code class="coded">assert compose(Elixir) == compose(music)</code>

      Paste existing code into the text editor, or write something from scratch. Type Alt+P to hear how it sounds. Initially it may seem like a chaotic mess. Type Alt+P again to pause. Adding, deleting, or refactoring may lead to more pleasant, harmonious, or musical output. Or not! What sounds "good" is a subjective judgment. What do your coder ears prefer?

      Create an account to add your code/compositions to the community database. Save an entire <code class="coded">defmodule</code>, or just one line!

      Pipesines is an open-source space where contributors are very much welcome. Future versions should improve on optimization, accessibility, and ideally, adding additional BEAM languages to the platform.

      Built using Elixir, Phoenix LiveView, Ecto, PostgresQL, and the excellent Tone.js

      Inspired by GEMS by @nbw, ElixirWPM by @tindrew, Max Mathews, Joan Miller, Laurie Spiegel, the monome community, Sonic Pi, SuperCollider, Tidal Cycles, algorave, ok all computer music programming ever, and all the sociotechnical wonders of the BEAM ecosystem.

      Special thanks to @brooklinjazz, @czrpb, @byronsalty, @IciaCarroBarallobre, @a-alhusaini, @BigSpaces, @w0rd-driven, and all my colleagues at DockYard Academy for their support and camaraderie.
      </p>

    """
  end
end

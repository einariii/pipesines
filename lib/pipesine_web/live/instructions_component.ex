defmodule PipesineWeb.CompositionLive.InstructionsComponent do
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
      Code to music to.
      <br><br>
      A web app that encourages Elixir developers to explore sound through code. Through magic* general programming becomes a specific sonic experience.
      <br><br>
      What do |> sound like? Which is more musical: if, case, or cond? Will Enum.filter actually filter a sound?
      <br><br>
      Compose Elixir/compose music.
      <br><br>
      Users have two options:
      <br><br>
          You are presented with code that could potentially use a refactoring. Initially it may sound like a chaotic mess. Refactoring may lead to more pleasant, harmonious, or musical output. What sounds "good" is a subjective judgment. What do your coder ears prefer? How far will you refactor?
      <br><br>
          You write code from scratch. Your first incantation initiates a basic drone. From there, write and listen until you are pleased with what you hear. Save your project after an entire defmodule, or after just one line!
      <br><br>
      Create an account to save and share your code/compositions.
      <br><br>
      Contributors welcome! I welcome suggestions and improvements—and would love to add additional languages to the platform.
      <br><br>
      Built using Elixir, Phoenix LiveView, Ecto, PostgresQL, Tone.js
      <br><br>
      Inspired by Nathan Willson's Gems, XYZ by Andevrs, Max Mathews, Joan Miller, Laurie Spiegel, the monome community, Sonic Pi, SuperCollider, Tidal Cycles, algorave, ok all computer music programming ever, and all the sociotechnical wonders of the BEAM ecosystem.
      </p>

    """
  end
end

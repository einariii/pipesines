defmodule PipesineWeb.PipesineLive.TechniqueComponent do
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
      <p>
        <br><br>
        <h1>WITH RESPECT TO TECHNIQUE</h1>
        Pipesines is designed for unusual or unfamiliar inspection of phenomena that may seem familiar to you (code and music, among other things). We want use to feel weird and confused. There is no guide, no user manual. Loosen your worries about understanding the system, and feel it, instead.

        That said, a few breadcrumbs and caveats:

        You only need a small number of characters to start getting sound—but too few, and the LiveView may crash.

        Extremely short "programs" (at least two lines and several characters) can be extremely vibrant. Unsurprisingly, the larger your codebase, the less effects tiny changes will have. Curiously, programs somewhere in the middle—say, a few dozen lines in length—may maintain recognizabilty after several changes large or small.

        In the REGEX version of the software, Tone.js reacts to a specific set of Elixir syntax and semantics, but broadly speaking it's just reacting to text input, so...

        Try other programming languages!

        Try other human languages

        Be careful with numbers!
      </p>
    """
  end
end

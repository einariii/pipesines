defmodule PipesineWeb.PipesineLive.TechniqueComponent do
  use PipesineWeb, :live_component

  # @impl true
  # def update(assigns, socket) do
  #   {:ok,
  #    socket
  #    |> assign(assigns)}
  # end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="vt323" id="tekne_modal">
        <p>
          <br><br>
          <h1 class="dotgothic16">With respect to technique</h1>
          Pipesines is designed for unfamiliar interaction with familiar phenomena (code and music, among other things). We want you to feel weird or confused. There is no user manual. Loosen your worries about understanding the system, and feel it, instead.

          That said, a few breadcrumbs and caveats:

          You only need a small number of characters to start getting sound—but too few, and the LiveView may crash.

          Extremely short "programs" (at least two lines and several characters) can be quite vibrant. Extremely long programs can be resilient to change. Programs somewhere in the middle—say, a few dozen lines in length—may seem harder to predict.

          <ul><i>Some suggestions to get you started:</i><br><br>
          <li>&emsp;Paste in code you are already familiar with!</li>
          <li>&emsp;Try find & replace!</li>
          <li>&emsp;Write garbage!</li>
          <li>&emsp;Listen to code smells.</li>
          <li>&emsp;Experiment with "Elixir-y" modules and syntax</li></ul>
          In the REGEX version of the software, Tone.js reacts to a specific set of Elixir syntax and semantics, but on the back-end Elixir is just analyzing text input, so you can play with other programming or written languages.

          Have fun. Be careful with numbers!
        </p>
      </div>
    """
  end
end

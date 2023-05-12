defmodule PipesineWeb.PipesineLive.LabelComponent do
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
        <h1> The Pipesines record label</h1>
          Pipesines is more than mere software. It is also an ethical project: it empowers users who have no musical experience to suddenly engage in music-making activity.

          But what happens after they close the browser? To be able to say that they are musicians, they must release their creations to the world.

          Hence, we have initiated a record label for users to share their code-compositions. Housed at <a href="https://pipesines.bandcamp.com">pipesines.bandcamp.com</a>, Pipesines Records welcomes contributions from the Elixir community and beyond.

          Please send an email to <code class="coded">p i p e s i n e s /at/ p r o t o n /dot/ m e</code> if you would like to participate! We will be delighted to help you shape your new artistic identity.
      </p>
    """
  end
end

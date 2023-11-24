defmodule PipesineWeb.PipesineLive.LabelComponent do
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
      <div class="vt323" id="label_modal">
        <p>
          <br><br>
          <h1 class="dotgothic16"> The Pipesines record label</h1>
            Pipesines is more than "mere" software. It has an ethical premise: to empower users who have no musical experience to suddenly engage in music-making activity.

            But what happens after they close the browser? Can we formalize our music-making to persist in time?

            Thinking in this spirit, we have initiated a record label for users to formally share their code-compositions as express musical works. Housed at <a href="https://pipesines.bandcamp.com">pipesines.bandcamp.com</a>, Pipesines Records welcomes contributions from the Elixir community and beyond.

            Please send an email to <code class="coded">p i p e s i n e s /at/ p r o t o n /dot/ m e</code> if you would like to participate! We will be delighted to help you shape your new artistic identity.
        </p>
      </div>
    """
  end
end

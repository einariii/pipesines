defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :connected, connected?(socket))}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <div id="container" class="background" style="width: 1200px; height: 600px; border: 9px solid black" phx-hook="Editor"></div>
    """
  end

  def handle_event("perform", params, socket) do
    IO.inspect(params)
    score = params["score"]

    seq_length = Regex.scan(~r/\n/, score) |> Enum.count()
    digits = Regex.scan(~r/\d/, score) |> Enum.count()
    characters = Regex.scan(~r/\w/, score) |> Enum.count()
    pipes = Regex.scan(~r/(?|>)/, score) |> Enum.count()


    length_div =
      case digits do
        0 -> 1
        _ -> digits
      end

    bits = abs(div(characters, 16))
    crusher =
      cond do
        bits <= 16 && bits >=4 -> bits
        true -> 16
      end

    chebyshev = pipes * characters + bits |> rem(100) |> abs()

    delay_time =
      cond do
        pipes >= 100 -> pipes * 0.001
        pipes >= 10 -> pipes * 0.01
        pipes >= 1 -> pipes * 0.1
        true -> 0.5
      end

    delay_feedback =
      cond do
        chebyshev >= 100 -> chebyshev * 0.001
        chebyshev >= 10 -> chebyshev * 0.01
        chebyshev >= 1 -> chebyshev * 0.1
        true -> 0.5
      end

    IO.inspect(pipes, label: "PIPES")
    IO.inspect(delay_time, label: "DELAYTIME")
    IO.inspect(delay_feedback, label: "DELAYFB")
    IO.inspect(chebyshev, label: "CHEBY")
    IO.inspect(params)

    note1 = seq_length / length_div * 100
    note2 = seq_length / length_div * 200
    note3 = seq_length / length_div * 300
    note4 = seq_length / length_div * 400
    note5 = seq_length / length_div * 500


    {:noreply, push_event(socket, "update_score", %{note1: note1, note2: note2, note3: note3, note4: note4, note5: note5, crusher: crusher, chebyshev: chebyshev, delayTime: delay_time, delayFeedback: delay_feedback})}
    # {:noreply, assign(socket, :score, params)}
  end

end

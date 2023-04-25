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

    IO.inspect(bits)
    IO.inspect(crusher)

    note1 = seq_length / length_div * 100
    note2 = seq_length / length_div * 200
    note3 = seq_length / length_div * 300
    note4 = seq_length / length_div * 400
    note5 = seq_length / length_div * 500


    {:noreply, push_event(socket, "update_score", %{note1: note1, note2: note2, note3: note3, note4: note4, note5: note5, crusher: crusher, delayTime: 0.4, delayFeedback: 0.6})}
    # {:noreply, assign(socket, :score, params)}
  end

end

defmodule PipesineWeb.PipesineLive.ManifestoComponent do
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
        <h1> On computing, music, and Elixir</h1>
          In 1957, at the Acoustical and Behavioral Research Center at Bell Laboratories in Murray Hill, New Jersey, <a href="https://en.wikipedia.org/wiki/Max_Mathews">Max Mathews</a> and <a href="https://www.researchgate.net/figure/Max-Mathews-with-Joan-Miller-Courtesy-Max-Mathews_fig4_220386665">Joan Miller</a> quietly ushered in a new age of listening to and being with technology. Their work, first on audio compilers and then on the <a href="https://120years.net/wordpress/music-n-max-mathews-usa-1957/">MUSIC N series of programming languages</a>, was instrumental in conceptualizing and realizing a given in today's world: <a href="https://www.frontiersin.org/articles/10.3389/fdigh.2018.00026/full">computers</a> are <a href="https://www.youtube.com/watch?v=E7WQ1tdxSqI">musical</a>.

          Approximately three decades later and six thousand kilometers away at an entirely different telecommuncations company, Ericsson engineers Joe Armstrong, Robert Virding, and Mike Williams unveiled their work on a language that, despite its elegant and music-friendly properties of low latency and high concurrency, has had almost no associaton with computer music: <a href="erlang.org/">Erlang</a>.

          Like its parent language, Elixir has many traits that make it an ideal candidate for sonic exploration and creation, but few projects have ventured in this direction. In the past few years, however, we hear hints of change: in the collaborative in-browser sequencer <a href="gems.nathanwillson.com/">GEMS</a>, <a href="https://dashbit.co/">Dashbit's</a> sponsorship of <a href="https://sonic-pi.net/">Sonic Pi</a>, DockYard's work on audio-speech recognition with <a href="https://dockyard.com/blog/2023/03/07/audio-speech-recognition-in-elixir-with-whisper-bumblebee">Whisper Bumblebee</a>, and in the fact that Chris McCord debuted the new LiveView UX with the music app <a href="https://livebeats.fly.dev/signin#">Livebeats</a>. Pipesines taps into a vibrant future potential, and aims to excite and accelerate it. We've been reading and writing on the BEAM for a while, and it feels good. Now, let's hear what it has to offer too.
      </p>
    """
  end
end

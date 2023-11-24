defmodule PipesineWeb.PipesineLive do
  use PipesineWeb, :live_view
  alias Phoenix.LiveView.JS
  # import Pipesine.Composers

  def mount(params, session, socket) do
    score = params["score"]
    is_mobile = Map.get(session, "is_mobile", false)

    {
      :ok,
      socket
      |> assign(toggle_modal: nil)
      |> assign(score: score)
      |> assign(is_mobile: is_mobile)
    }
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    IO.inspect(assigns, label: "ASSINGS IN LV")

    ~H"""
    <div class="vt323">
      <nav class="menuright">
      <button phx-click={JS.toggle(to: "#about_modal", in: "fade-in", out: "fade-out")} class="nav-button">:about</button>
        <div class="vt323 phx-modal" id="about_modal">
          <h1 class="dotgothic16">Pipesines. Elixir as musical instrument.</h1>
          Pipesines (v0.1.0) is a web app that encourages Elixir developers to explore sound through code: general programming as a specific sonic experience.

          What do <code class="coded">|></code> sound like? Which is more musical: <code class="coded">if</code>, <code class="coded">case</code>, or <code class="coded">cond</code>? Will <code class="coded">Enum.filter</code> actually filter a sound? And what about <code class="coded">Enum.reduce</code>?

          <code class="coded">assert compose(Elixir) == compose(music)</code>

          Paste existing code into the text editor, or write something from scratch. Type <code class="coded">alt+p</code> to hear how it sounds. Initially it may seem like a chaotic mess. Type <code class="coded">alt+p</code> again to pause. Adding, deleting, or refactoring may lead to more pleasant, harmonious, or musical output. Or not! What sounds "good" is a subjective judgment. What do your coder ears prefer?

          Create an account to add your code/compositions to the community database. Save an entire <code class="coded">defmodule</code>, or just one line!

          Pipesines is an open-source space where contributors are very much welcome. Future versions should improve on optimization, accessibility, and ideally, adding additional BEAM languages to the platform.

          Built using Elixir, Phoenix LiveView, Ecto, PostgresQL, and the excellent <a href="https://tonejs.github.io/">Tone.js</a>

          Inspired by GEMS by @nbw, Beats by @mtrudel, Max Mathews, Joan Miller, Laurie Spiegel, the monome community, Sonic Pi, SuperCollider, Tidal Cycles, algorave, ok all computer music programming ever, and all the sociotechnical wonders of the BEAM ecosystem.

          Special thanks to @brooklinjazz, @czrpb, @byronsalty, @IciaCarroBarallobre, @a-alhusaini, @BigSpaces, @w0rd-driven, and all my colleagues at DockYard Academy for their support and camaraderie.
        </div>

        <button phx-click={JS.toggle(to: "#ethos_modal", in: "fade-in", out: "fade-out")} class="nav-button">:ethos</button>
        <div class="vt323 phx-modal" id="ethos_modal">
          <h1 class="dotgothic16"> On computing, music, and Elixir</h1>
            In 1957, at the Acoustical and Behavioral Research Center at Bell Laboratories in Murray Hill, New Jersey, <a href="https://en.wikipedia.org/wiki/Max_Mathews/">Max Mathews</a> and <a href="https://www.researchgate.net/figure/Max-Mathews-with-Joan-Miller-Courtesy-Max-Mathews_fig4_220386665/">Joan Miller</a> quietly ushered in a new age of listening to and being with technology. Their work, first on audio compilers and then on the <a href="https://120years.net/wordpress/music-n-max-mathews-usa-1957/">MUSIC N series of programming languages</a>, was instrumental in conceptualizing and realizing a given in today's world: <a href="https://www.frontiersin.org/articles/10.3389/fdigh.2018.00026/full/">computers</a> are <a href="https://www.youtube.com/watch?v=E7WQ1tdxSqI/">musical</a>.

            Approximately three decades later and six thousand kilometers away at an entirely different telecommuncations company, Ericsson engineers Joe Armstrong, Robert Virding, and Mike Williams <a href="https://erlang.org/download/erlang-book-part1.pdf">unveiled their work on a language</a> that, despite its elegant and music-friendly properties of low latency and high concurrency, has had almost no associaton with computer music: <a href="https://erlang.org/">Erlang</a>.

            Like its parent language, <a href="https://elixir-lang.org/">Elixir</a> has many traits that make it an ideal candidate for sonic exploration and creation, but few projects have ventured in this direction. In the past few years, however, we hear hints of change: in the collaborative in-browser sequencer <a href="https://gems.nathanwillson.com/">GEMS</a>, Dashbit's sponsorship of <a href="https://sonic-pi.net/">Sonic Pi</a> and its Elixir/Erlang refactoring, DockYard's work on audio-speech recognition with <a href="https://dockyard.com/blog/2023/03/07/audio-speech-recognition-in-elixir-with-whisper-bumblebee/">Whisper Bumblebee</a>, and in the fact that Chris McCord debuted the new LiveView UX with a music app called <a href="https://livebeats.fly.dev/">LiveBeats</a>. Pipesines taps into a vibrant future potential, poised to excite and accelerate it. We've been reading and writing on the BEAM for a while, and it feels good. Let's start listening to it, too.
        </div>

        <button phx-click={JS.toggle(to: "#tekne_modal", in: "fade-in", out: "fade-out")} class="nav-button">:tekne</button>
        <div class="vt323 phx-modal" id="tekne_modal">
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
        </div>

        <button phx-click={JS.toggle(to: "#label_modal", in: "fade-in", out: "fade-out")} class="nav-button">:label</button>
        <div class="vt323 phx-modal" id="label_modal">
        <h1 class="dotgothic16"> The Pipesines record label</h1>
        Pipesines is more than "mere" software. It has an ethical premise: to empower users who have no musical experience to suddenly engage in music-making activity.

        But what happens after they close the browser? Can we formalize our music-making to persist in time?

        Thinking in this spirit, we have initiated a record label for users to formally share their code-compositions as express musical works. Housed at <a href="https://pipesines.bandcamp.com">pipesines.bandcamp.com</a>, Pipesines Records welcomes contributions from the Elixir community and beyond.

        Please send an email to <code class="coded">p i p e s i n e s /at/ p r o t o n /dot/ m e</code> if you would like to participate! We will be delighted to help you shape your new artistic identity.
        </div>
      </nav>
    </div>
    <div class="text-editor">
      <div class="fake-buttons">
        <div class="tooltip versions"><button class="vt323" disabled>REGEX mode</button>
          <span class="tooltiptext">current default<br>PCRE regular expressions!</span>
        </div>
        <div class="tooltip versions"><button class="vt323" disabled>AST mode</button>
          <span class="tooltiptext">future implementation<br>ABSTRACT SYNTAX TREE!</span>
        </div>
        <div class="tooltip versions"><button class="vt323" disabled>ML mode</button>
          <span class="tooltiptext">future implementation<br>MACHINE LEARNING!</span>
        </div>
      </div>

      <div id="editor" class="filtered" style="width: 120rem; height: 60rem; border: 3px solid #000" phx-hook="Editor"></div>

      <div class="fake-buttons">
        <div class="tooltip versions"><button class="vt323" style="margin-top: 8px" disabled>play code</button>
          <span class="tooltiptext">TO HEAR YOUR ELIXIR<br>type alt+p (opt+p on mac)<br>in the editor!</span>
        </div>
        <div class="tooltip versions"><button class="vt323" style="margin-top: 8px" disabled>it sounds glitchy</button>
          <span class="tooltiptext">LET IT GLITCH<br>
          <br>
          ...or refresh the page</span>
        </div>
        <div class="tooltip versions"><button class="vt323" style="margin-top: 8px" disabled>scales</button>
          <span class="tooltiptext">set scale on the first line.<br />
          options = 22_edo, bohlen_pierce, sa_murcchana, tonality_diamond, just_intonation, pentatonic.<br />
          default = superpyth</span>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("perform", params, socket) do
    score = Pipesine.Sound.compose_composition(params["score"])

    {:noreply,
     socket
     |> assign(score: params["score"])
     |> push_event("update_score", score)}
  end

  def handle_event("save", _params, socket) do
    if socket.assigns.composer_id do
      Pipesine.Sound.create_composition(%{
        score: socket.assigns.score,
        composer_id: socket.assigns.composer_id
        # composer_username: socket.assigns.composer_username,
        # composer_email: socket.assigns.composer_email
      })
    else
      put_flash(
        socket,
        :error,
        "You must be logged in to save (you must also evaluate before attempting to save!)"
      )
    end

    {:noreply, socket}
  end
end

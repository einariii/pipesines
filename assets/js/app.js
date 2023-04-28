// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import * as Tone from "../vendor/tone.js"

import * as monaco from 'monaco-editor/esm/vs/editor/editor.main.js';

// self.MonacoEnvironment = {
// 	getWorkerUrl: function (moduleId, label) {
// 		if (label === 'json') {
// 			return './vs/language/json/json.worker.js';
// 		}
// 		if (label === 'css' || label === 'scss' || label === 'less') {
// 			return './vs/language/css/css.worker.js';
// 		}
// 		if (label === 'html' || label === 'handlebars' || label === 'razor') {
// 			return './vs/language/html/html.worker.js';
// 		}
// 		if (label === 'typescript' || label === 'javascript') {
// 			return './vs/language/typescript/ts.worker.js';
// 		}
// 		return './vs/editor/editor.worker.js';
// 	}
// };

let Hooks = {
  Editor: {
    getSynth(instrument) {
      switch (instrument) {
        case "AMSynth":
          return new Tone.AMSynth();
        case "FMSynth":
          return new Tone.FMSynth();
        case "MetalSynth":
          return new Tone.MetalSynth();
        case "NoiseSynth":
          return new Tone.NoiseSynth();
        case "PluckSynth":
          return new Tone.PluckSynth();
        default:
          return new Tone.MembraneSynth();
      }
    },

    // insertNotes(notes) {
    //   switch (notes) {
    //     case "all_notes":
    //       return [params.note1, params.note2, params.note3, params.note4, params.note5];
    //     case "two_notes":
    //       return [params.note3, params.note4];
    //     default:
    //       return [params.note1];
    //   }
    // },

    mounted() {
      let editor = monaco.editor.create(this.el, {
        value: ['# pipesines', '# |> software for writing music in pure Elixir', '# |> start coding/composing here', '# |> use headphones please', '# |> alt + p to perform'].join('\n'),
        language: 'elixir',
        theme: "vs-dark"
      });

      editor.onKeyUp((event) => {
        event.preventDefault();
        // my keyboard identifies "p" keycode as 46 but the internet states it should be 80
        if (event.altKey && (event.keyCode == 46 || event.keyCode == 80)) {
          this.pushEvent("perform", { score: editor.getValue() });
        }
      });

      this.handleEvent("update_score", (params) => {
        const synth = new Tone.PolySynth();
        const synth2 = this.getSynth(params.instrument2);
        const synth3 = this.getSynth(params.instrument3);
        const vibrato = new Tone.Vibrato(params.vibratoFrequency, params.vibratoDepth);
        // const chebyshev = new Tone.Chebyshev(params.chebyshev); // range 1-100
        const crusher = new Tone.BitCrusher(params.crusher); // range 1-16
        // const filter = new Tone.Filter(params.filterFrequency, params.filterType, params.filterRolloff); // rolloff -12/-24/-48/-96 types "lowpass", "highpass", "bandpass", "lowshelf", "highshelf", "notch", "allpass", or "peaking"
        const panner = new Tone.Panner(params.panner); // -1 to 1
        // const delay = new Tone.PingPongDelay(params.delayTime, params.delayFeedback); // time and delay both 0 to 1
        const reverb = new Tone.Reverb(params.reverbDecay, params.reverbWet);
        const limiter = new Tone.Limiter(-48);
        const compressor = new Tone.Compressor(-24, 3);
        // const humanize = new Tone.Pattern.humanize(params.humanize)
        // const seq3 = new Tone.Pattern((time, note) => {
        //   synth3.triggerAttackRelease(note, 0.12, time);
        // }, [params.note3, params.note5, params.note4, params.note4], params.pattern);
        // const array3 = new Array(params.array3);
        const seq2 = new Tone.Sequence((time, note) => {
          synth2.triggerAttackRelease(note, 0.2, time);
        }, [params.array3, params.array2]);
        const seq3 = new Tone.Pattern((time, note) => {
          synth3.triggerAttackRelease(note, 0.05, time);
        }, params.array3, params.pattern)
        // Tone.Transport.timeSignature = 7;

        // var lfo = new Tone.LFO("2n", params.filterFrequency, 1000);
        // lfo.connect(vibrato.frequency);

        synth.connect(vibrato);
        vibrato.connect(crusher);
        // chebyshev.connect(crusher);
        crusher.connect(compressor);
        // filter.connect(compressor);
        compressor.toDestination();

        synth2.connect(panner);
        panner.connect(limiter);
        limiter.connect(compressor);
        compressor.toDestination();

        synth3.connect(reverb);
        reverb.connect(compressor);
        // delay.connect(compressor);
        compressor.toDestination();

        if (Tone.Transport.state == "started") {
          Tone.Transport.stop();
          Tone.Transport.cancel();
          console.log(Tone.Transport.state)
        } else {
          /* allow users to toggle? */
          // const seq = new Tone.Sequence((time, note) => {
          //   synth.triggerAttackRelease(note, 0.24, time);
          // }, [params.note1, params.note1, params.note2, [params.note3, params.note5], params.note4, params.note2, params.note3, params.note3]).start(0);

          seq2.start(0);

          seq3.start(0);

          // console.log(array3)
          Tone.Transport.start();
        }
      })
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())
// window.addEventListener("phx:perform", event => {
//     let params = event.detail
// })

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
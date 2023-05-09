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
        case "PolySynth":
          return new Tone.PolySynth();
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

    mounted() {
      let editor = monaco.editor.create(this.el, {
        value: [
          '# binaural BEAM', 
          '',
          'defmodule Pipesine.Example do',
          '    @moduledoc """',
          '        pipesines v0.1 (REGEX version only)',
          '        software for writing music in pure Elixir', 
          '        alt + P to perform/pause',
          '        if desired, set scale on the first line.',
          '            options = {',
          '                22_edo,',
          '                bohlen_pierce,',
          '                sa_murcchana,',
          '                tonality_diamond,',
          '                just_intonation,',
          '                pentatonic',
          '            }',
          '            default =',
          '                superpyth',
          '        sound is stereo. use headphones',
          '        may contain high frequencies. exercise caution',
          '        spend time exploring small changes!',
          '    """',
          '',
          '    def a_pipesine do',
          '        # modify this code',
          '        # or write your own',
          '    end',
          'end'
        ].join('\n'),
        language: 'elixir',
        theme: "hc-black"
      });

      editor.onKeyUp((event) => {
        event.preventDefault();
        // my keyboard identifies "p" keycode as 46 but the internet states it should be 80
        if (event.altKey && (event.keyCode == 46 || event.keyCode == 80)) {
          this.pushEvent("perform", { score: editor.getValue() });
        }
      });

      this.handleEvent("update_score", (params) => {
        const synth = this.getSynth(params.instrument1);
        const synth2 = this.getSynth(params.instrument2);
        const synth3 = this.getSynth(params.instrument3);
        // const vibrato = new Tone.Vibrato(params.fundamental, params.vibratoDepth);
        const chebyshev = new Tone.Chebyshev(params.chebyshev); // range 1-100
        const crusher = new Tone.BitCrusher(params.crusher); // range 1-16
        const panner = new Tone.Panner(params.panner); // -1 to 1
        const delay = new Tone.PingPongDelay(params.delayTime, params.delayFeedback); // time and delay both 0 to 1
        const phaser = new Tone.Phaser({ frequency: params.atoms, octaves: params.atoms, baseFrequency: params.note6 })
        // const pitchShift = new Tone.PitchShift(params.timeSignature);
        const reverb = new Tone.Reverb(params.reverbDecay, params.reverbWet);
        const limiter = new Tone.Limiter(-36);
        const limiter2 = new Tone.Limiter(-72);
        const compressor = new Tone.Compressor(-24, 3);
        Tone.Transport.bpm.value = params.tempo;
        Tone.Transport.swing.value = params.swing;
        Tone.Transport.swingSubdivision.value = params.swingSubdivision;
        Tone.Transport.timeSignature = params.timeSignature;
        Tone.Context.lookAhead = 0;
        var filter = new Tone.Filter(params.filterFrequency, "lowpass", -24);
        var filter2 = new Tone.Filter(params.filter2Frequency, "lowpass", -48);
        var filter3 = new Tone.Filter(params.filter3Frequency, "notch", -48);
        var lfo = new Tone.LFO(params.timeSignature, 500, 600); // hertz, min, max
        var lfo2 = new Tone.LFO(params.hashes, 200, 1200); // hertz, min, max
        lfo.connect(filter.frequency);
        lfo.connect(reverb.wet);
        lfo.start();
        lfo2.connect(phaser.frequency);
        lfo2.start();

        // const latency = Tone.setContext(new Tone.Context({ latencyHint : "playback" }));

        const seq = new Tone.Pattern((time, note) => {
          synth.triggerAttackRelease(note, params.delayFeedback, time);
        }, params.phrase, params.pattern);

        const seq2 = new Tone.Sequence((time, note) => {
          synth2.triggerAttackRelease(note, params.reverbWet, time);
        }, params.phrase2);

        const seq3 = new Tone.Pattern((time, note) => {
          synth3.triggerAttackRelease(note, params.reverbDecay, time);
        }, params.phrase3, params.pattern3);

        synth.connect(panner)
        // vibrato.connect(panner);
        panner.connect(filter);
        filter.connect(crusher);
        crusher.connect(limiter2);
        limiter.connect(compressor);
        compressor.toDestination();

        synth2.connect(delay);
        delay.connect(chebyshev);
        chebyshev.connect(filter2);
        filter2.connect(limiter);
        limiter2.connect(compressor);
        compressor.toDestination();

        synth3.connect(filter3);
        filter3.connect(reverb);
        reverb.connect(phaser);
        phaser.connect(compressor);
        compressor.toDestination();

        if (Tone.Transport.state == "started") {
          Tone.Transport.stop();
          Tone.Transport.cancel();
          console.log(Tone.Transport.state)
        } else {
          /* allow users to toggle? */
          // Tone.Transport.clear();
          seq.start(0);
          seq2.start(0);
          seq3.start(0);
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
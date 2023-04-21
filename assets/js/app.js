// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
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
    BasicPlay: {
      mounted() {
        this.handleEvent("update_score", (params) => {
          const synth = new Tone.PolySynth();
          const synth2 = new Tone.FMSynth();
          const vibrato = new Tone.Vibrato(params.vibratoFrequency, params.vibratoDepth);
          const chebyshev = new Tone.Chebyshev(params.chebyshev); // range 1-100
          const crusher = new Tone.BitCrusher(params.crusher); //range 1-16
          const filter = new Tone.Filter(params.filterFrequency, params.filterType, params.filterRolloff); //rolloff -12/-24/-48/-96 types "lowpass", "highpass", "bandpass", "lowshelf", "highshelf", "notch", "allpass", or "peaking"
          const panner = new Tone.Panner(params.panner); // -1 to 1
          const delay = new Tone.PingPongDelay(params.delayTime, params.delayFeedback); //time and delay both 0 to 1
          const reverb = new Tone.Reverb(params.reverbDecay, params.reverbWet);
          const compressor = new Tone.Compressor(-30, 4);
            
          /**
           * Audio effects chain:
          *
          * [PolySynth] --> [Vibrato] --> [Chebyshev] --> [Crusher] --> [Filter] --> ... --> Output
            */
          synth.connect(vibrato);
          vibrato.connect(chebyshev);
          chebyshev.connect(crusher);
          crusher.connect(compressor);
          // filter.connect(panner);
          // panner.connect(delay);
          // delay.connect(reverb);
          // reverb.connect(compressor);
          compressor.toDestination();
          
          synth2.connect(delay);
          delay.connect(reverb);
          reverb.connect(compressor);
          compressor.toDestination();
  
          // synth.triggerAttackRelease(params.note1, "8t");
          
          const seq = new Tone.Sequence((time, note) => {
            synth.triggerAttackRelease(note, 0.1, time);
            // subdivisions are given as subarrays
          }, ["C2", params.note1, params.note2, ["Ab4", "Fb4"], "Gb4", params.note2]).start(0);
          Tone.Transport.start();
          
          // const now = Tone.now()
          // synth.triggerAttackRelease(params.note1, "8t", now);
          // synth2.triggerAttackRelease(params.note2, "4n", now + 0.3);
          // synth.triggerAttackRelease(params.note1, "2n", now + 0.5);
          // synth2.triggerAttackRelease(params.note2, "8t", now + 1.1);
          
          //LOOP
          // const loopA = new Tone.Loop(time => {
            //   synth2.triggerAttackRelease(params.note2, "8t", time);
            // }, "1n").start(0);
          // Tone.Transport.start();
          // Tone.Transport.bpm.rampTo(800, 20);
  
          console.log(params)
        })
  
        this.el.addEventListener("input", () => {
        }) 
      }
    },
    // ClickHook: {
    //   mounted() {
    //     this.el.addEventListener("click", () => {
    //       console.log(editor.getValue())
    //     })
    //   }
    // },
    Editor: {
      mounted() {
        let editor = monaco.editor.create(this.el, {
          value: ['# PipeSines', '# software for writing music in pure Elixir', '# start coding/composing here'].join('\n'),
          language: 'elixir',
          theme: "vs-dark"
        });
        
        editor.onDidChangeModelContent(() => {
          //* add push event here
          console.log(editor.getValue())
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
export default {
    mounted() {
        window.addEventListener("phx:custom_event:toggle-about", function (event) {
            document.querySelector("#dynamic-about").classList.toggle("hidden");
        });
    }
}
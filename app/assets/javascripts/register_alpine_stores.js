document.addEventListener('alpine:init', () => {
    Alpine.store('navigation', {
        on: true,

        toggle() {
            this.on = !this.on
        }
    })
})

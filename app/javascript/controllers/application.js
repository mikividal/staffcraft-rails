import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Forzar logs
application.debug = true
console.error("🚨 Stimulus Application Iniciada")

window.Stimulus = application

export { application }

// app/javascript/controllers/analysis_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  constructor(context) {
    super(context)
    console.error("🚨 CONSTRUCTOR Analysis Controller")
  }

  initialize() {
    console.error("🏁 INITIALIZE Analysis Controller")
  }

  connect() {
    console.error("🎯 CONNECT Analysis Controller")
    console.error("Elemento:", this.element)
    debugger; // Añade un breakpoint forzado
  }
}

// app/javascript/controllers/test_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.error("🧪 Test Controller Connected")
  }
}

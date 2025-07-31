import { application } from "./application"

import { Controller } from "@hotwired/stimulus"

const controllers = import.meta.glob("./*_controller.js", { eager: true })

Object.entries(controllers).forEach(([path, module]) => {
  const controllerName = path
    .replace("./", "")
    .replace("_controller.js", "")
    .replace(/_/g, "-")

  application.register(controllerName, module.default)
})

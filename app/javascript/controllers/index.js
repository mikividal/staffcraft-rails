// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
// import DaterangeController from "./daterange_controller"
// application.register("daterange", DaterangeController)
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// import MapController from "./map_controller"
// application.register("map", MapController)

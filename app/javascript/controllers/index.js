// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import BottomSheetController from "./bottom_sheet_controller"
application.register("bottom-sheet", BottomSheetController)

import FloatingHeaderController from "./floating_header_controller"
application.register("floating-haeder", FloatingHeaderController)

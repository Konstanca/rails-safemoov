import { Controller }   from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

    toggle() {
      if (this.hasMenuTarget && this.hasOverlayTarget) {
        this.menuTarget.classList.toggle("active")
        this.hasOverlayTarget.classList.toggle("active")
      }
    }

    close() {
      if (this.hasMenuTarget && this.hasOverlayTarget) {
        this.menuTarget.classList.remove("active")
        this.hasOverlayTarget.classList.remove("active")
      }
    }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // static targets = []

  connect() {
    this.expanded = false
  }

  toggle() {
    this.expanded = !this.expanded
    this.element.classList.toggle("expanded", this.expanded)
    this.element.classList.toggle("collapsed", !this.expanded)
  }

  expand() {
    this.expanded = true
    this.element.classList.add("expanded")
    this.element.classList.remove("collapsed")
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["trigger"];

  connect() {
    console.log("Float menu controller connecté !");
  }

  toggle(event) {
    event.preventDefault();
    this.element.classList.toggle("active"); // Toggle la classe "active"
  }
}

// app/javascript/controllers/notifications_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["offcanvas"];

  toggleOffcanvas() {
    this.offcanvasTarget.classList.toggle("show");
  }

  markAsRead(event) {
    const notificationId = event.currentTarget.dataset.notificationId;
    fetch(`/notifications/${notificationId}/mark_as_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
    }).then(() => {
      // Le Turbo Stream mettra à jour automatiquement via ActionCable
    });
  }
}

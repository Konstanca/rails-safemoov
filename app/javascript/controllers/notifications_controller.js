// app/javascript/controllers/notifications_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Notifications controller connecté !");
  }

  markAsRead(event) {
    event.preventDefault();
    event.stopPropagation(); // Empêche la propagation de l'événement
    console.log("markAsRead déclenché !");
    const link = event.currentTarget;
    const notificationId = link.dataset.notificationId;
    const card = link.closest(".card");
    console.log("Marquage comme lu :", notificationId);

    fetch(`/notifications/${notificationId}/mark_as_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html" // Demande explicitement une réponse turbo_stream
      }
    }).then(response => {
      console.log("Réponse statut :", response.status);
      if (response.status === 200) {
        // Traite la réponse turbo_stream
        response.text().then(html => {
          document.body.insertAdjacentHTML("beforeend", html); // Applique la mise à jour Turbo Stream
          card.remove();
          const badge = document.querySelector(".notifications .badge");
          const currentCount = badge ? parseInt(badge.textContent) : 0;
          console.log("Badge avant :", currentCount);
          if (currentCount > 1) {
            badge.textContent = currentCount - 1;
          } else if (badge) { // Vérifie que badge existe avant de faire remove()
            badge.remove();
          }
          window.location.href = link.getAttribute("href");
        });
      } else if (response.status === 302) {
        card.remove();
        const badge = document.querySelector(".notifications .badge");
        const currentCount = badge ? parseInt(badge.textContent) : 0;
        console.log("Badge avant :", currentCount);
        if (currentCount > 1) {
          badge.textContent = currentCount - 1;
        } else if (badge) { // Vérifie que badge existe avant de faire remove()
          badge.remove();
        }
        window.location.href = response.headers.get("Location");
      } else {
        console.log("Erreur : Statut inattendu", response.status);
      }
    }).catch(error => console.error("Erreur fetch :", error));
  }
}

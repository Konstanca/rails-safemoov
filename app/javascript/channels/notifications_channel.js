// app/javascript/channels/notifications_channel.js
import consumer from "./consumer";
console.log("NotificationsChannel chargé");

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connecté au canal de notifications !");
  },
  disconnected() {
    console.log("Déconnecté.");
  },
  received(data) {
    console.log("Reçu :", data);
    const offcanvasBody = document.querySelector("#notificationsOffcanvas .offcanvas-body");
    const badge = document.querySelector(".notifications .badge");

    if (data.action === "remove") {
      // Supprime la carte
      const card = document.querySelector(`[data-notification-id="${data.notification_id}"]`);
      if (card) {
        card.remove();
      }
      // Met à jour le badge
      const currentCount = badge ? parseInt(badge.textContent) : 0;
      if (currentCount > 1) {
        badge.textContent = currentCount - 1;
      } else if (badge) { // Vérifie que badge existe avant de faire remove()
        badge.remove();
      }
    } else {
      // Ajoute une nouvelle notification
      if (offcanvasBody) {
        const notificationHtml = `
          <div class="card" data-notification-id="${data.notification_id}">
            <a href="/incidents/${data.incident_id}" data-action="click->notifications#markAsRead" data-notification-id="${data.notification_id}">
              <div class="card-body">${data.incident_title}</div>
            </a>
          </div>
        `;
        offcanvasBody.insertAdjacentHTML("afterbegin", notificationHtml);
      } else {
        console.error("Offcanvas non trouvé !");
      }

      // Met à jour le badge
      const currentCount = badge ? parseInt(badge.textContent) || 0 : 0;
      if (badge) {
        badge.textContent = currentCount + 1;
      } else {
        document.querySelector(".notifications").insertAdjacentHTML("beforeend", `<span class="badge">1</span>`);
      }

      // Ouvre l’offcanvas (à supprimer si tu ne veux pas qu’il s’ouvre automatiquement)
      // const offcanvas = document.querySelector("#notificationsOffcanvas");
      // offcanvas.classList.add("show");
    }
  }
});

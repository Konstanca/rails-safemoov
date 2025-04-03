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
    const badge = document.querySelector(".notification-bell .badge"); // Corrigé ici

    if (data.action === "remove") {
      const card = document.querySelector(`[data-notification-id="${data.notification_id}"]`);
      if (card) {
        card.remove();
      }
      const currentCount = badge ? parseInt(badge.textContent) : 0;
      if (currentCount > 1) {
        badge.textContent = currentCount - 1;
      } else if (badge) {
        badge.remove();
      }
    } else {
      if (offcanvasBody) {
        const notificationHtml = `
          <div class="card" data-notification-id="${data.notification_id}">
            <a href="/incidents/${data.incident_id}" data-action="click->notifications#markAsRead" data-notification-id="${data.notification_id}">
              <div class="card-body">
                <strong><i class="fa-solid fa-circle-exclamation"></i> Nouveau</strong>
                <h5>${data.incident_title}</h5>
                <h6>à ${data.incident_address}</h6>
                <small>${data.incident_created_at}</small>
            </a>
          </div>
        `;
        offcanvasBody.insertAdjacentHTML("beforeend", notificationHtml);
      } else {
        console.log("Offcanvas fermé, mise à jour en attente.");
        // Stocker la notif si tu veux la gérer plus tard (optionnel)
      }

      const currentCount = badge ? parseInt(badge.textContent) || 0 : 0;
      if (badge) {
        badge.textContent = currentCount + 1;
      } else {
        document.querySelector(".notification-bell").insertAdjacentHTML("beforeend", `<span class="badge">1</span>`);
      }
    }
  }
});

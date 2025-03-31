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
    const offcanvas = document.querySelector("#notificationsOffcanvas");
    const badge = document.querySelector(".badge");

    // Ajoute la nouvelle notification
    const notificationHtml = `
      <div class="card">
        <a href="/incidents/${data.incident_id}" data-action="click->notifications#markAsRead" data-notification-id="${data.notification_id}">
          <div class="card-body">${data.incident_title}</div>
        </a>
      </div>
    `;
    offcanvas.insertAdjacentHTML("afterbegin", notificationHtml);

    // Met à jour le badge
    const currentCount = badge ? parseInt(badge.textContent) || 0 : 0;
    if (badge) {
      badge.textContent = currentCount + 1;
    } else {
      document.querySelector(".notifications").insertAdjacentHTML("beforeend", `<span class="badge">1</span>`);
    }

    offcanvas.classList.add("show");
  }
});

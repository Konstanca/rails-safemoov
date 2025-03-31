// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

console.log("Début de application.js");

import "./channels/consumer"; // Charge le consumer
import "./channels/notifications_channel"; // Charge le channel spécifique

import flatpickr from "flatpickr"
import { French } from "flatpickr/dist/l10n/fr"

document.addEventListener("turbo:load", () => {
  console.log("Turbo chargé");
  const dateInput = document.querySelector("#incident_date");
  if (dateInput) {
    flatpickr(dateInput, {
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      time_24hr: true,
      altInput: true,
      altFormat: "d/m/Y à H:i",
      locale: French,
      maxDate: "today",
      defaultDate: dateInput.value || null
    });
  }
});

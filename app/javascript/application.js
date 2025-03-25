// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

import flatpickr from "flatpickr"
import { French } from "flatpickr/dist/l10n/fr"

document.addEventListener("turbo:load", () => {
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

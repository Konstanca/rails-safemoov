// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

import toastr from "toastr";

window.toastr = toastr; // Rendre Toastr disponible globalement
toastr.options = {
  "closeButton": false,
  "debug": false,
  "newestOnTop": false,
  "progressBar": true,
  "positionClass": "toast-top-right",
  "preventDuplicates": true,
  "onclick": null,
  "showDuration": "300",   // Temps d'entrée (raisonnable)
  "hideDuration": "0",     // Temps de sortie réduit à 0 pour un effacement instantané
  "timeOut": "2500",       // Durée d'affichage totale
  "extendedTimeOut": "0",  // Pas de délai supplémentaire après interaction
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
};

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

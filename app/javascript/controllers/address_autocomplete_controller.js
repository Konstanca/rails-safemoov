import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
// Supprimez l'import CSS ici

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static values = { apiKey: String };
  static targets = ["address"];

  connect() {
    console.log("🔍 Initialisation address-autocomplete");


    if (!this.apiKeyValue) {
      console.error("Mapbox API key is missing");
      return;
    }

    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      placeholder: "Recherche d'incidents par localité...",
      mapboxgl: window.mapboxgl,
      types: "country,region,place,postcode,locality,neighborhood,address",
    })

    this.geocoder.addTo(this.element)

    // Gestion de la sélection d'un lieu
    this.geocoder.on("result", (e) => {
      const coords = e.result.center

      // Vol vers la localisation
      if (window.mapboxMap) {
        window.mapboxMap.flyTo({ center: coords, zoom: 13 })
      }

      // Replier automatiquement le bottom sheet
      const sheet = this.element.closest(".bottom-sheet")
      if (sheet) {
        sheet.classList.remove("expanded")
        sheet.classList.add("collapsed")
      }
    })

    // Expansion du bottom sheet au focus sur l'input
    setTimeout(() => {
      const input = this.element.querySelector(".mapboxgl-ctrl-geocoder--input")
      if (input) {
        input.addEventListener("focus", () => {
          const sheet = this.element.closest(".bottom-sheet")
          if (sheet) {
            sheet.classList.add("expanded")
            sheet.classList.remove("collapsed")
          }
        })
      }
    }, 500);
  }

  disconnect() {
    if (this.geocoder) {
      this.geocoder.onRemove();
    }
  }
}

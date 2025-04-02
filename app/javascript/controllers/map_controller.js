import { Controller } from "@hotwired/stimulus"

import mapboxgl from 'mapbox-gl' // Don't forget this!
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder" // search in map

// Connects to data-controller="map"
export default class extends Controller {

  static values = {
    apiKey: String,
    markers: Array,
    currentUser: Object
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    // private methods in javascript are prepend with #
    // this.#addClustersToMap()
    this.#addMarkersToMap()
    this.#fitMapToMarkers()

    // search in map
    this.map.addControl(new MapboxGeocoder({ accessToken: mapboxgl.accessToken, mapboxgl: mapboxgl }))

    console.log("🔍 currentUserValue récupéré :", this.currentUserValue) // Ajout de log

    // Vérifier si currentUser et lat/lng sont définis et zoomer sur la position
    if (this.currentUserValue && this.currentUserValue.lat && this.currentUserValue.lng) {
      this.#addCurrentUserMarker(this.currentUserValue.lat, this.currentUserValue.lng)
      this.map.setCenter([this.currentUserValue.lng, this.currentUserValue.lat])
      this.map.setZoom(12) // Ajuster le niveau de zoom
    } else {
      console.warn("❌ Aucune position utilisateur trouvée")
    }
    // Ajouter le bouton "Localiser current_user"
    document.getElementById('center-user-btn').addEventListener('click', () => {
      if (this.currentUserValue && this.currentUserValue.lat && this.currentUserValue.lng) {
        this.map.easeTo({
          center: [this.currentUserValue.lng, this.currentUserValue.lat],
          zoom: 12
        });
      } else {
        console.warn("❌ Aucune position utilisateur pour recentrer la carte");
      }
    });
  }

  #addCurrentUserMarker(lat, lng) {
    const customMarker = document.createElement("div")
    customMarker.classList.add("marker", "marker-user")
    customMarker.innerHTML = `<i class="fas fa-user" style="font-size: 18px; color: white;"></i>`

    new mapboxgl.Marker(customMarker)
      .setLngLat([lng, lat])
      .addTo(this.map)
  }

  #addMarkersToMap() {
    // Définir les icones FontAwesome
    const categoryIconsClasses = {
      "Attaque à main armée": "fas fa-people-robbery",
      "Assassinat": "fas fa-skull",
      "Enlèvement": "fa-solid fa-hands-bound",
      "Prise d’otages": "fa-solid fa-hands-bound",
      "Éboulement": "fa-solid fa-volcano",
      "Inondation": "fa-solid fa-volcano",
      "Tremblement de terre": "fa-solid fa-volcano",
      "Vol à l’étalage": "fas fa-people-robbery",
      "Agression": "fas fa-people-robbery",
      "Trafic de drogue": "fas fa-cannabis",
      "Émeute": "fas fa-users",
      "Incendie": "fas fa-fire",
      "Accident de la route": "fas fa-car-crash",
      "Fraude électorale": "fas fa-sack-dollar",
      "Manifestation violente": "fas fa-bullhorn",
      "Disparition": "fa-solid fa-person-circle-question",
      "Braquage de voiture": "fas fa-people-robbery"
    };

    const categoryGroups = {
      "very-high-gravity": ["Enlèvement", "Attaque à main armée", "Assassinat", "Prise d’otages", "Émeute"],
      "high-gravity": ["Tremblement de terre", "Disparition", "Manifestation violente"],
      "moderate-gravity": ["Inondation", "Fraude électorale", "Trafic de drogue", "Agression"],
      "low-gravity": ["Vol à l’étalage", "Éboulement",  "Incendie", "Accident de la route", "Braquage de voiture"]
    };

    const colorMapping = {
      "very-high-gravity": "#A50021",
      "high-gravity": "#FF5733",
      "moderate-gravity": "#F39C12",
      "low-gravity": "#F4D03F"
    };


    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html);

      const customMarker = document.createElement("div");
      customMarker.className = "marker";

      const iconClass = categoryIconsClasses[marker.category] || "fas fa-exclamation-circle";

      // Trouver la couleur associée
      let backgroundColor = "#808080"; // Par défaut gris
      for (const [color, categories] of Object.entries(categoryGroups)) {
        if (categories.includes(marker.category)) {
          backgroundColor = colorMapping[color];
          break;
        }
      }

      customMarker.innerHTML = `<i class="${iconClass}" style="font-size: 16px; color: white;"></i>`;

      // Appliquer le style au marqueur
      customMarker.style.backgroundColor = backgroundColor;
      customMarker.style.borderRadius = "50%";
      customMarker.style.width = "30px";
      customMarker.style.height = "30px";
      customMarker.style.display = "flex";
      customMarker.style.justifyContent = "center";
      customMarker.style.alignItems = "center";

      new mapboxgl.Marker(customMarker)
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup)
        .addTo(this.map);
    });

  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 12, duration: 0 })
  }

  #addClustersToMap() {
    // todo

  }
}

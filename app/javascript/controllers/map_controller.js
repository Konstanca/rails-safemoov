import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    currentUser: Object
  }

  connect() {
    // Vérifier si déjà initialisé via l'élément DOM
    if (this.element.dataset.mapInitialized === 'true') return;
    this.element.dataset.mapInitialized = 'true';

    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    });

    window.mapboxMap = this.map;

    this.#addMarkersToMap();

    if (this.currentUserValue && this.currentUserValue.lat && this.currentUserValue.lng) {
      this.#addCurrentUserMarker(this.currentUserValue.lat, this.currentUserValue.lng);
    }

    const urlParams = new URLSearchParams(window.location.search);
    const incidentLng = urlParams.get('lng');
    const incidentLat = urlParams.get('lat');

    // Restaurer la position précédente sans animation comme point de départ
    const savedPosition = JSON.parse(localStorage.getItem('mapPosition'));
    if (savedPosition) {
      console.log("🔄 Restauration position précédente:", savedPosition);
      this.map.jumpTo({
        center: [savedPosition.lng, savedPosition.lat],
        zoom: savedPosition.zoom
      });
    } else if (this.currentUserValue && this.currentUserValue.lat && this.currentUserValue.lng) {
      // Si pas de position sauvegardée, démarrer sur l'utilisateur
      console.log("👤 Position initiale sur utilisateur:", this.currentUserValue.lng, this.currentUserValue.lat);
      this.map.jumpTo({
        center: [this.currentUserValue.lng, this.currentUserValue.lat],
        zoom: 12
      });
    } else {
      console.log("📍 Position initiale sur tous les marqueurs");
      this.#fitMapToMarkers();
    }

    // Si paramètres d'incident, animer depuis la position actuelle vers l'incident
    if (incidentLng && incidentLat) {
      console.log("🎯 Animation vers incident:", incidentLng, incidentLat);
      this.map.flyTo({
        center: [parseFloat(incidentLng), parseFloat(incidentLat)],
        zoom: 15,
        speed: 1.2,
        curve: 1.4
      });
    } else if (!savedPosition && this.currentUserValue && this.currentUserValue.lat && this.currentUserValue.lng) {
      // Si pas d'incident ni de position sauvegardée, animer vers l'utilisateur
      console.log("👤 Animation vers utilisateur:", this.currentUserValue.lng, this.currentUserValue.lat);
      this.map.flyTo({
        center: [this.currentUserValue.lng, this.currentUserValue.lat],
        zoom: 12,
        speed: 1.2,
        curve: 1.4
      });
    }

    // Sauvegarder la position quand la carte bouge
    this.map.on('moveend', () => {
      const center = this.map.getCenter();
      const zoom = this.map.getZoom();
      localStorage.setItem('mapPosition', JSON.stringify({
        lng: center.lng,
        lat: center.lat,
        zoom: zoom
      }));
      console.log("💾 Position sauvegardée:", { lng: center.lng, lat: center.lat, zoom });
    });

    const centerUserBtn = document.getElementById('center-user-btn');
    if (centerUserBtn) {
      centerUserBtn.addEventListener('click', () => {
        if (this.currentUserValue && this.currentUserValue.lat && this.currentUserValue.lng) {
          console.log("👤 Recentrer sur utilisateur via bouton");
          this.map.flyTo({
            center: [this.currentUserValue.lng, this.currentUserValue.lat],
            zoom: 12,
            speed: 1.2,
            curve: 1.4
          });
          window.history.pushState({}, document.title, '/incidents');
        } else {
          console.warn("❌ Aucune position utilisateur pour recentrer la carte");
        }
      });
    }
  }

  #addCurrentUserMarker(lat, lng) {
    const customMarker = document.createElement("div");
    customMarker.classList.add("marker", "marker-user");
    customMarker.innerHTML = `<i class="fas fa-user" style="font-size: 18px; color: white;"></i>`;

    const popup = new mapboxgl.Popup().setHTML("<b>Vous êtes ici</b>");

    new mapboxgl.Marker(customMarker)
      .setLngLat([lng, lat])
      .setPopup(popup)
      .addTo(this.map);
  }

  #addMarkersToMap() {
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
      "low-gravity": ["Vol à l’étalage", "Éboulement", "Incendie", "Accident de la route", "Braquage de voiture"]
    };

    const colorMapping = {
      "very-high-gravity": "#A50021",
      "high-gravity": "#FF5733",
      "moderate-gravity": "#F39C12",
      "low-gravity": "#F4D03F"
    };

    this.markersValue.forEach((marker) => {
      const customMarker = document.createElement("div");
      customMarker.className = "marker";
      const iconClass = categoryIconsClasses[marker.category] || "fas fa-exclamation-circle";

      let backgroundColor = "#808080";
      for (const [color, categories] of Object.entries(categoryGroups)) {
        if (categories.includes(marker.category)) {
          backgroundColor = colorMapping[color];
          break;
        }
      }

      customMarker.innerHTML = `<i class="${iconClass}" style="font-size: 16px; color: white;"></i>`;
      customMarker.style.backgroundColor = backgroundColor;
      customMarker.style.borderRadius = "50%";
      customMarker.style.width = "30px";
      customMarker.style.height = "30px";
      customMarker.style.display = "flex";
      customMarker.style.justifyContent = "center";
      customMarker.style.alignItems = "center";

      const mapboxMarker = new mapboxgl.Marker(customMarker)
        .setLngLat([marker.lng, marker.lat])
        .addTo(this.map);

      customMarker.addEventListener("click", () => {
        fetch(`/incidents/${marker.id}/info_window`)
          .then(response => response.text())
          .then(html => {
            const popup = new mapboxgl.Popup({ offset: 25 })
              .setLngLat([marker.lng, marker.lat])
              .setHTML(html)
              .addTo(this.map);
          })
          .catch(error => {
            console.error("❌ Erreur lors du chargement de la popup :", error);
          });
      });
    });
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    this.markersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]));
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 12, duration: 0 });
  }

  #addClustersToMap() {
    // todo
  }
}

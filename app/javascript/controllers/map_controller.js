import { Controller } from "@hotwired/stimulus"

import mapboxgl from 'mapbox-gl' // Don't forget this!
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder" // search in map

// Connects to data-controller="map"
export default class extends Controller {

  static values = {
    apiKey: String,
    markers: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    // private methods in javascript are prepend with #
    this.#addMarkersToMap()
    this.#fitMapToMarkers()

    // search in map
    this.map.addControl(new MapboxGeocoder({ accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl }))
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
      "Fraude électorale": "fas fa-ballot-box",
      "Manifestation violente": "fas fa-bullhorn",
      "Disparition": "fa-solid fa-person-circle-question",
      "Braquage de voiture": "fas fa-people-robbery"
    };
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html)
      // marqueur  FontAwesome
      const customMarker = document.createElement("div")
      //customMarker.className = "marker"
      const iconClass = categoryIconsClasses[marker.category] || "fas fa-exclamation-circle"
      customMarker.innerHTML = `<i id="bulle" class="${iconClass}" style="font-size: 24px; color:rgb(48, 48, 48)"></i>`
      new mapboxgl.Marker(customMarker)
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup)
        .addTo(this.map)
    })
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }

  #addClustersToMap() {
    // todo

  }
}

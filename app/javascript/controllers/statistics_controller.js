// app/javascript/controllers/statistics_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radius", "months", "categoryChart", "categoryTitle", "trendsContainer", "trendChart", "trendsTitle", "totalIncidents"];

  connect() {
    this.categoryChartInstance = null;
    this.trendChartInstances = {};
    console.log("Controller connected, categoryTitleTarget:", this.hasCategoryTitleTarget);
    console.log("Controller connected, totalIncidentsTarget:", this.hasTotalIncidentsTarget);
    console.log("Controller connected, trendsTitleTarget:", this.hasTrendsTitleTarget);
    this.renderCharts();
  }

  disconnect() {
    if (this.categoryChartInstance) this.categoryChartInstance.destroy();
    Object.values(this.trendChartInstances).forEach(instance => instance.destroy());
  }

  updateCharts() {
    const incidentId = this.element.dataset.statisticsIncidentId;
    const radius = this.radiusTarget.value || 5;
    const months = this.monthsTarget.value;

    console.log(`Fetching data with radius: ${radius}, months: ${months}`);

    fetch(`/statistics/local/${incidentId}?radius=${radius}&months=${months}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then(data => {
        console.log("Data received:", data);
        this.element.dataset.statisticsStats = JSON.stringify(data.stats);
        this.element.dataset.statisticsTrends = JSON.stringify(data.trends);
        this.renderCharts();
      })
      .catch(error => console.error("Erreur lors du fetch:", error));
  }

  renderCharts() {
    const stats = JSON.parse(this.element.dataset.statisticsStats);
    const trends = JSON.parse(this.element.dataset.statisticsTrends);
    const months = parseInt(this.monthsTarget.value); // Convertir en nombre

    console.log("Rendering charts, months:", months);

    // Mettre à jour le titre de la répartition avec gestion du pluriel
    if (this.hasCategoryTitleTarget) {
      if (months === 1) {
        this.categoryTitleTarget.textContent = "Répartition par catégorie (dernier mois)";
      } else {
        const newTitle = `Répartition par catégorie (derniers ${months} mois)`;
        this.categoryTitleTarget.textContent = newTitle;
      }
    } else {
      console.error("categoryTitleTarget not found!");
    }

    // Mettre à jour le titre des tendances
    if (this.hasTrendsTitleTarget) {
      if (months === 1) {
        this.trendsTitleTarget.textContent = "Tendances des 5 principales catégories (dernier mois)";
      } else {
        const newTrendsTitle = `Tendances des 5 principales catégories (derniers ${months} mois)`;
        this.trendsTitleTarget.textContent = newTrendsTitle;
      }
    } else {
      console.error("trendsTitleTarget not found!");
    }

    // Mettre à jour le total des incidents
    if (this.hasTotalIncidentsTarget) {
      const total = stats.total || 0;
      console.log("Updating total incidents to:", total);
      this.totalIncidentsTarget.textContent = `Total des incidents : ${total}`;
    } else {
      console.error("totalIncidentsTarget not found!");
    }

    // Définir les icônes (codes Unicode de Font Awesome) pour l'axe X et les titres
    const categoryIconsUnicode = {
      "Attaque à main armée": "\ue536", // fa-people-robbery
      "Assassinat": "\uf54c", // fa-skull
      "Enlèvement": "\uf70c", // fa-person-running
      "Prise d’otages": "\ue4f8", // fa-handcuffs
      "Éboulement": "\uf6fc", // fa-mountain
      "Inondation": "\uf773", // fa-water
      "Tremblement de terre": "\ue3b1", // fa-house-crack
      "Vol à l’étalage": "\uf4bd", // fa-hand-holding
      "Agression": "\uf6de", // fa-fist-raised
      "Trafic de drogue": "\uf55f", // fa-cannabis
      "Émeute": "\uf0c0", // fa-users
      "Incendie": "\uf06d", // fa-fire
      "Accident de la route": "\uf5e1", // fa-car-crash
      "Fraude électorale": "\uf466", // fa-ballot-box
      "Manifestation violente": "\uf0a1", // fa-bullhorn
      "Disparition": "\uf007", // fa-user
      "Braquage de voiture": "\uf1b9", // fa-car-side
    };

    // Graphique des catégories
    if (this.categoryChartInstance) this.categoryChartInstance.destroy();
    this.categoryChartInstance = new Chart(this.categoryChartTarget, {
      type: "bar",
      data: {
        labels: Object.keys(stats.by_category),
        datasets: [{
          label: "Nombre d’incidents par catégorie",
          data: Object.values(stats.by_category),
          backgroundColor: "29647C", // Couleur de fond des barres
          borderColor: "#29647C", // Couleur des bordures des barres",
          borderWidth: 1,
          barPercentage: 0.8 // Ajuster la largeur des barres pour un meilleur alignement
        }]
      },
      options: {
        plugins: {
          legend: {
            display: false // Optionnel : désactiver la légende si elle n'est pas nécessaire
          },
          tooltip: {
            callbacks: {
              // Afficher le nom de la catégorie dans le tooltip
              label: function(context) {
                const label = context.label || '';
                const value = context.raw;
                return `${label}: ${value} incidents`;
              }
            }
          }
        },
        scales: {
          x: {
            ticks: {
              // Personnaliser les labels de l'axe X pour afficher des icônes Font Awesome
              callback: function(value, index, values) {
                const label = this.getLabelForValue(value);
                return categoryIconsUnicode[label] || label; // Retourne le code Unicode ou le nom si pas d'icône
              },
              font: {
                family: "'Font Awesome 6 Free'", // Utiliser la police Font Awesome
                size: 14, // Taille des icônes
                weight: '900' // Poids de la police (nécessaire pour Font Awesome)
              },
              autoSkip: false, // Désactiver le saut automatique des labels
              maxRotation: 45, // Incliner les icônes à 45 degrés pour éviter le chevauchement
              minRotation: 45,
              align: 'center' // Assure que les labels sont centrés sous les ticks
            }
          },
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1, precision: 0 }
          }
        },
        maintainAspectRatio: false,
        responsive: true
      }
    });

    // Graphiques des tendances
    if (this.hasTrendsContainerTarget) {
      this.trendsContainerTarget.innerHTML = "";
      Object.values(this.trendChartInstances).forEach(instance => instance.destroy());
      this.trendChartInstances = {};

      const trendsData = Object.entries(trends.top_categories).reduce((acc, [key, count]) => {
        const [cat, month] = key.split("|");
        acc[cat] = acc[cat] || {};
        acc[cat][month] = count;
        return acc;
      }, {});
      const monthsList = [...new Set(Object.keys(trends.totals))].sort((a, b) => {
        const [monthA, yearA] = a.split("/").map(Number);
        const [monthB, yearB] = b.split("/").map(Number);
        const dateA = new Date(yearA, monthA - 1);
        const dateB = new Date(yearB, monthB - 1);
        return dateA - dateB;
      });
      const categories = Object.keys(trendsData);

      console.log("Trends data:", trendsData);
      console.log("Months list (sorted):", monthsList);
      console.log("Categories:", categories);

      if (categories.length === 0) {
        this.trendsContainerTarget.innerHTML = "<p>Aucune donnée de tendance disponible pour ce rayon.</p>";
        return;
      }

      categories.forEach((category, index) => {
        const canvasId = `trendChart${index}`;
        const html = `
          <div class="card mb-3">
            <div class="card-body">
              <h3 class="card-title trend-icon">${category}</h3>
              <div class="chart-container">
                <canvas id="${canvasId}" data-statistics-target="trendChart" data-category="${category}"></canvas>
              </div>
            </div>
          </div>
        `;
        this.trendsContainerTarget.insertAdjacentHTML("beforeend", html);

        const canvas = this.trendsContainerTarget.querySelector(`#${canvasId}`);
        const dataset = {
          label: category,
          data: monthsList.map(m => trendsData[category][m] || 0),
          fill: false,
          borderColor: "#29647C",
          tension: 0.1
        };

        this.trendChartInstances[category] = new Chart(canvas, {
          type: "line",
          data: {
            labels: monthsList,
            datasets: [dataset]
          },
          options: {
            scales: {
              y: {
                beginAtZero: true,
                ticks: { stepSize: 1, precision: 0 }
              }
            },
            plugins: { legend: { display: false } },
            maintainAspectRatio: false,
            responsive: true
          }
        });
      });
    }
  }
}

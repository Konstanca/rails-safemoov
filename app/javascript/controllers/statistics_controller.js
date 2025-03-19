// app/javascript/controllers/statistics_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radius", "months", "categoryChart", "trendsContainer", "trendChart"];

  connect() {
    this.categoryChartInstance = null;
    this.trendChartInstances = {};
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
    const months = this.monthsTarget.value;

    // Graphique des catégories
    if (this.categoryChartInstance) this.categoryChartInstance.destroy();
    this.categoryChartInstance = new Chart(this.categoryChartTarget, {
      type: "bar",
      data: {
        labels: Object.keys(stats.by_category),
        datasets: [{
          label: "Nombre d’incidents par catégorie",
          data: Object.values(stats.by_category),
          backgroundColor: "rgba(75, 192, 192, 0.2)",
          borderColor: "rgba(75, 192, 192, 1)",
          borderWidth: 1
        }]
      },
      options: {
        scales: {
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
              <h3 class="card-title">${category}</h3>
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
          borderColor: `hsl(${(index * 60) % 360}, 70%, 50%)`,
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

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radius", "months", "categoryChart", "trendsChart"];

  connect() {
    this.categoryChartInstance = null;
    this.trendsChartInstance = null;
    this.renderCharts();
  }

  disconnect() {
    if (this.categoryChartInstance) this.categoryChartInstance.destroy();
    if (this.trendsChartInstance) this.trendsChartInstance.destroy();
  }

  updateCharts() {
    const incidentId = this.element.dataset.statisticsIncidentId;
    const radius = this.radiusTarget.value || 5;
    const months = this.monthsTarget.value;

    fetch(`/statistics/local/${incidentId}?radius=${radius}&months=${months}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        return response.json();
      })
      .then(data => {
        this.element.dataset.statisticsStats = JSON.stringify(data.stats);
        this.element.dataset.statisticsTrends = JSON.stringify(data.trends);
        this.renderCharts();
      })
      .catch(error => console.error("Erreur lors du fetch:", error));
  }

  renderCharts() {
    const stats = JSON.parse(this.element.dataset.statisticsStats);
    const trends = JSON.parse(this.element.dataset.statisticsTrends);

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
      options: { scales: { y: { beginAtZero: true } } }
    });

    // Graphique des tendances
    if (this.trendsChartInstance) this.trendsChartInstance.destroy();
    const trendsData = Object.entries(trends.by_category).reduce((acc, [key, count]) => {
      const [cat, month] = key.split("|"); // Diviser la clé en catégorie et mois
      acc[cat] = acc[cat] || {};
      acc[cat][month] = count;
      return acc;
    }, {});
    const months = [...new Set(Object.keys(trends.totals))]; // Tous les mois uniques
    const categories = Object.keys(trendsData);

    const categoryDatasets = categories.map(cat => ({
      label: cat,
      data: months.map(m => trendsData[cat][m] || 0),
      fill: false,
      borderColor: `hsl(${Math.random() * 360}, 70%, 50%)`,
      borderWidth: 1,
      tension: 0.5
    }));

    const cumulativeDataset = {
      label: "Cumul",
      data: months.map(m => trends.totals[m] || 0),
      fill: true,
      borderColor: "#000000",
      borderWidth: 1,
      tension: 0.5
    };

    const datasets = [...categoryDatasets, cumulativeDataset];

    this.trendsChartInstance = new Chart(this.trendsChartTarget, {
      type: "line",
      data: { labels: months, datasets },
      options: { scales: { y: { beginAtZero: true } } }
    });
  }
}

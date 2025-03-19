class Statistic
  include ActiveModel::Model

  def self.local_statistics(incident, radius: 5.0, months: 3)
    return { total: 0, by_category: {} } unless incident.latitude && incident.longitude
    start_date = months.months.ago
    resolved_incidents = Incident.where(status: false)
      .where("created_at >= ?", start_date)
      .near([incident.latitude, incident.longitude], radius, units: :km)
      .to_a # Charge une fois en mémoire

    {
      total: resolved_incidents.size,
      by_category: resolved_incidents.group_by(&:category).transform_values(&:size)
    }
  end

  def self.local_trends(incident, radius: 5.0)
    return { by_category: {}, totals: {} } unless incident.latitude && incident.longitude
    start_date = 6.months.ago
    resolved_incidents = Incident.where(status: false)
      .where("created_at >= ?", start_date)
      .near([incident.latitude, incident.longitude], radius, units: :km)
      .to_a # Charge une fois en mémoire

    # Calculer le total par catégorie sur toute la période
    category_totals = resolved_incidents.group_by(&:category).transform_values(&:size)
    # Sélectionner les 5 catégories les plus fréquentes
    top_5_categories = category_totals.sort_by { |_, count| -count }.first(5).to_h

    # Données par mois pour toutes les catégories
    by_category = resolved_incidents
                          .group_by { |i| "#{i.category}|#{i.created_at.beginning_of_month.strftime('%m/%Y')}" }
                          .transform_values(&:size)
    # Totaux par mois (toutes catégories)
    totals_by_month = resolved_incidents.group_by { |i| i.created_at.beginning_of_month.strftime("%m/%Y") }
                                .transform_values(&:size)
    # Filtrer les données pour les 5 catégories principales
    top_category_trends = by_category.select { |key, _| top_5_categories.key?(key.split("|").first) }

    {
      by_category: by_category, # Toutes les données (pour référence)
      totals: totals_by_month,  # Totaux mensuels (toutes catégories)
      top_categories: top_category_trends # Données des 5 principales
    }
  end
end

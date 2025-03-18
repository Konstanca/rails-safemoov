# app/models/statistic.rb
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

  def self.local_trends(incident, radius: 5.0, months: 3)
    return { by_category: {}, totals: {} } unless incident.latitude && incident.longitude
    start_date = months.months.ago
    resolved_incidents = Incident.where(status: false)
      .where("created_at >= ?", start_date)
      .near([incident.latitude, incident.longitude], radius, units: :km)
      .to_a # Charge une fois en mémoire

    by_category = resolved_incidents.group_by { |i| "#{i.category}|#{i.created_at.beginning_of_month.strftime('%B %Y')}" }
                          .transform_values(&:size)
    totals_by_month = resolved_incidents.group_by { |i| i.created_at.beginning_of_month.strftime("%B %Y") }
                                .transform_values(&:size)

    { by_category: by_category, totals: totals_by_month }
  end
end

# app/models/statistic.rb
class Statistic
  include ActiveModel::Model

  def self.local_statistics(incident, radius: 5.0, months: 3)
    start_date = months.months.ago
    resolved_incidents = Incident.where(status: false)
      .where("created_at >= ?", start_date)
      .select do |i|
        distance = Geocoder::Calculations.distance_between(
          [incident.latitude, incident.longitude],
          [i.latitude, i.longitude],
          units: :km
        )
        distance <= radius
      end

    {
      total: resolved_incidents.size,
      by_category: resolved_incidents.group_by(&:category).transform_values(&:size),
      confirmation_rate: calculate_confirmation_rate(resolved_incidents)
    }
  end

  def self.local_trends(incident, radius: 5.0, months: 3)
    start_date = months.months.ago
    resolved_incidents = Incident.where(status: false)
      .where("created_at >= ?", start_date)
      .select do |i|
        distance = Geocoder::Calculations.distance_between(
          [incident.latitude, incident.longitude],
          [i.latitude, i.longitude],
          units: :km
        )
        distance <= radius
      end

    by_category = resolved_incidents.group_by { |i| "#{i.category}|#{i.created_at.beginning_of_month.strftime('%B %Y')}" }
                          .transform_values(&:size)
    totals_by_month = resolved_incidents.group_by { |i| i.created_at.beginning_of_month.strftime("%B %Y") }
                                .transform_values(&:size)

    { by_category: by_category, totals: totals_by_month }
  end

  private_class_method def self.calculate_confirmation_rate(incidents)
    return 0 if incidents.empty?
    total_votes = incidents.sum { |i| i.vote_count_plus + i.vote_count_minus }
    return 0 if total_votes.zero?
    (incidents.sum(&:vote_count_plus).to_f / total_votes * 100).round(2)
  end
end

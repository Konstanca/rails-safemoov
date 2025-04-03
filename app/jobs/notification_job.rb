# app/jobs/notification_job.rb
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(incident)
    Rails.logger.info "NotificationJob triggered for incident #{incident.id}"
    Alert.where.not(latitude: nil, longitude: nil).find_each do |alert|
      distance = Geocoder::Calculations.distance_between(
        [alert.latitude, alert.longitude],
        [incident.latitude, incident.longitude],
        units: :km
      )
      Rails.logger.info "Distance to alert #{alert.id} (User #{alert.user_id}): #{distance} km, radius: #{alert.radius}"
      if distance && distance <= alert.radius
        notification = alert.notifications.create(user: alert.user, incident: incident, read: false)
        Rails.logger.info "Notification #{notification.id} créée pour User #{alert.user.id}"

        # Envoie des données brutes au lieu de HTML
        NotificationsChannel.broadcast_to(alert.user, {
          notification_id: notification.id,
          incident_id: notification.incident.id,
          incident_title: notification.incident.title
        })
      end
    end
  end
end

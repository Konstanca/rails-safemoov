# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    Rails.logger.info "Avant mark_as_read: #{@notification.inspect}"
    @notification.mark_as_read
    Rails.logger.info "Après mark_as_read: #{@notification.inspect}"

    respond_to do |format|
      format.turbo_stream do
        # Diffuse la mise à jour via ActionCable
        NotificationsChannel.broadcast_to(
          current_user,
          notification_id: @notification.id,
          action: "remove"
        )
        # Supprime la carte côté client
        render turbo_stream: turbo_stream.remove("notification_#{@notification.id}")
      end
      format.html { redirect_to incident_path(@notification.incident) }
    end
  end
end

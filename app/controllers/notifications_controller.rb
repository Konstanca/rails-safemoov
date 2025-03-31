# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read
    redirect_to incident_path(@notification.incident)
  end
end

# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    Rails.logger.info "User #{current_user.id} subscribed to NotificationsChannel"
  end

  def unsubscribed
    Rails.logger.info "User #{current_user.id} unsubscribed from NotificationsChannel"
  end
end

# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :alert
  belongs_to :incident

  scope :unread, -> { where(read: false) }

  def mark_as_read
    update(read: true)
  end
end

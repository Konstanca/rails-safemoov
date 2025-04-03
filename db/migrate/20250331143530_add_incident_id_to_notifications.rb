class AddIncidentIdToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_reference :notifications, :incident, foreign_key: true
  end
end

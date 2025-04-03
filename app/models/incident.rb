class Incident < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :user
  has_many :notifications, dependent: :destroy

  has_one_attached :photo


  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  after_create :notify_subscribed_users

  def confirmed_votes_count
    votes.where(vote: true).count
  end

  def contested_votes_count
    votes.where(vote: false).count
  end

  private

  def notify_subscribed_users
    Rails.logger.info "Triggering NotificationJob for incident #{id}"
    NotificationJob.perform_later(self)
  end
end

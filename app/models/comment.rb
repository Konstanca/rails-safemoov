class Comment < ApplicationRecord
  belongs_to :incident
  belongs_to :user

  validates :content, presence: true
  validates :incident_id, presence: true
  validates :user_id, presence: true
end

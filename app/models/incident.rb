class Incident < ApplicationRecord
  has_many :votes
  has_many :comments
  belongs_to :user

  # source of geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end

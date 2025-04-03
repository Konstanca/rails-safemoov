# app/models/alert.rb
class Alert < ApplicationRecord
  belongs_to :user
  has_many :notifications, dependent: :destroy

  # Champs nécessaires : address, latitude, longitude, radius
  validates :address, :radius, presence: true
  validates :radius, numericality: { greater_than: 0 }

  # Geocoding avec Geocoder
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end

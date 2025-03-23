class Incident < ApplicationRecord
  has_many :votes
  has_many :comments, dependent: :destroy
  belongs_to :user


  # source of geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  geocoded_by :coordinates
  def coordinates
    [latitude, longitude]
  end
end

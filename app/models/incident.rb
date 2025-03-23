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

  def confirmed_votes_count
    votes.where(vote: true).count
  end

  def contested_votes_count
    votes.where(vote: false).count
  end
end

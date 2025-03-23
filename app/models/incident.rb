class Incident < ApplicationRecord
  has_many :votes
  has_many :comments
  belongs_to :user

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

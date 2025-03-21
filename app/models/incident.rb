class Incident < ApplicationRecord
  has_many :votes
  has_many :comments, dependent: :destroy
  belongs_to :user

  geocoded_by :coordinates
  def coordinates
    [latitude, longitude]
  end
end

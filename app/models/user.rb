class User < ApplicationRecord
  has_many :alerts
  has_many :incidents
  has_many :comments
  has_many :notifications
  has_many :votes

  has_one_attached :photo

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def display_name
    nickname.presence || email
  end
end

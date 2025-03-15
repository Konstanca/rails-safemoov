class User < ApplicationRecord
  has_many :alerts
  has_many :incidents
  has_many :comments
  has_many :notifications
  has_many :votes
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :incident

  # Validation pour empêcher un utilisateur de voter plusieurs fois pour le même incident
  validates :user_id, uniqueness: { scope: :incident_id, message: "Vous avez déjà voté pour cet incident." }
end

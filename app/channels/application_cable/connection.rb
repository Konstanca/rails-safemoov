# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info "ActionCable connecté pour User #{current_user.id}"
    end

    private

    def find_verified_user
      if (current_user = env['warden'].user) # Devise stocke l'utilisateur dans warden
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end

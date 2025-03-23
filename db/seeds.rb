# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Nettoyage des tables dans le bon ordre pour éviter les erreurs de dépendance
Incident.destroy_all if defined?(Incident)
puts "Table incident nettoyée !"
Comment.destroy_all
puts "Table comment nettoyée !"
Vote.destroy_all
puts "Table vote nettoyée !"
Notification.destroy_all
puts "Table notification nettoyée !"
User.destroy_all
puts "Table users nettoyée !"

# Création des 3 utilisateurs (compatible avec Devise)
users = [
  User.new(email: "Meg.Doe@safemoov.com", first_name: "Meg", last_name: "Doe", nickname: "Meg", password: "password123"),
  User.new(email: "Jane.Smith@safemoov.com", first_name: "Jane", last_name: "Smith", nickname: "Janie", password: "password123"),
  User.new(email: "John.Wilson@safemoov.com", first_name: "John", last_name: "Wilson", nickname: "Johnny", password: "password123")
]

users.each_with_index do |user, index|
  begin
    user.save!
    puts "Utilisateur #{index + 1} (#{user.email}) créé avec succès !"
  rescue StandardError => e
    puts "Erreur lors de la création de l'utilisateur #{index + 1} : #{e.message}"
  end
end
puts "#{User.count} utilisateurs ajoutés à la base de données !"

# Creation des incidents
incidents = [
  # Incidents créées par John Doe
  { title: "Vol", description: "pickpocket", address: "Metro Auber, grands magasins", status: true, category: "Vol", user_id: users[0].id, latitude: 48.8722239, longitude: 2.3298028, vote_count_plus: 12, vote_count_minus: 32 },
  { title: "Vol", description: "pickpocket", address: "Grands magasins, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.862725, longitude: 2.287592, vote_count_plus: 5, vote_count_minus: 1 },
  { title: "Vol", description: "pickpocket", address: "Galeries Lafayette, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.87363052368164, longitude: 2.332015037536621, vote_count_plus: 10, vote_count_minus: 2 },
  { title: "Vol", description: "pickpocket", address: "Printemps, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.873887, longitude: 2.3290507, vote_count_plus: 1, vote_count_minus: 10 },

  # Incidents cxréés par Jane Smith
  { title: "Violence", description: "aggression", address: "Parc Vincennes, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.873145, longitude: 2.328431, vote_count_plus: 12, vote_count_minus: 32 },
  { title: "Bagarre", description: "aggression", address: "Les quais de la Seine", status: true, category: "Vol", user_id: users[0].id, latitude: 48.860305, longitude: 2.331692, vote_count_plus: 5, vote_count_minus: 1 },
  { title: "Insulte", description: "aggression", address: "Tour Eiffel, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.858092, longitude: 2.295361, vote_count_plus: 1, vote_count_minus: 10 },

  # Incidents créés par Mike Wilson
  { title: "Vol", description: "pickpocket", address: "Metro Ecole Militaire, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.854961, longitude: 2.306447, vote_count_plus: 12, vote_count_minus: 32 },
  { title: "Vol", description: "braquage", address: "Metro gare de Lyon, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.844304, longitude: 2.374377 , vote_count_plus: 5, vote_count_minus: 1 },
  { title: "Vol", description: "braquage", address: "Louvre, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.868822 , longitude:  2.309805, vote_count_plus: 10, vote_count_minus: 2 },
  { title: "Vol", description: "pickpocket", address: "Metro Chatelet, Paris", status: true, category: "Vol", user_id: users[0].id, latitude: 48.8681267, longitude: 2.3652302, vote_count_plus: 1, vote_count_minus: 10 },

]

incidents.each_with_index do |incident_data, index|
  begin
    incident = Incident.new(incident_data)
    incident.save!
    puts "Incident #{index + 1} (#{incident_data[:title]}) créé avec succès !"
  rescue StandardError => e
    puts "Erreur lors de la création de l'incident #{index + 1} : #{e.message}"
  end
end

# create_table "incidents", force: :cascade do |t|
#   t.string "title"
#   t.text "description"
#   t.string "address"
#   t.boolean "status"
#   t.string "category"
#   t.bigint "user_id", null: false
#   t.string "photo_url"
#   t.float "latitude"
#   t.float "longitude"
#   t.integer "vote_count_plus"
#   t.integer "vote_count_minus"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["user_id"], name: "index_incidents_on_user_id"
# end

require 'faker'
require 'geocoder'

# Réinitialiser les tables dans l’ordre inverse des dépendances
puts "Réinitialisation des tables..."
Vote.destroy_all
Comment.destroy_all
Notification.destroy_all
Incident.destroy_all
Alert.destroy_all
User.destroy_all

# Créer des utilisateurs
puts "Création de 50 utilisateurs..."
50.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now)
  )
end

# Liste des catégories d'incidents
categories = [
  "Attaque à main armée",
  "Assassinat",
  "Enlèvement",
  "Prise d’otages",
  "Éboulement",
  "Inondation",
  "Tremblement de terre",
  "Vol à l’étalage",
  "Agression",
  "Trafic de drogue",
  "Émeute",
  "Incendie",
  "Accident de la route",
  "Fraude électorale",
  "Manifestation violente"
]

# Principales villes d’Équateur avec coordonnées (latitude, longitude)
cities = {
  "Quito" => { latitude: -0.1807, longitude: -78.4678 },
  "Guayaquil" => { latitude: -2.1894, longitude: -79.8891 },
  "Cuenca" => { latitude: -2.9005, longitude: -79.0045 },
  "Santo Domingo" => { latitude: -0.2532, longitude: -79.1719 },
  "Machala" => { latitude: -3.2586, longitude: -79.9554 },
  "Manta" => { latitude: -0.9677, longitude: -80.7089 },
  "Portoviejo" => { latitude: -1.0546, longitude: -80.4525 },
  "Ambato" => { latitude: -1.2417, longitude: -78.6198 },
  "Riobamba" => { latitude: -1.6710, longitude: -78.6483 },
  "Loja" => { latitude: -3.9931, longitude: -79.2042 }
}

# Générer des coordonnées aléatoires autour d’une ville
def city_coordinates(city_coords)
  {
    latitude: city_coords[:latitude] + Faker::Number.between(from: -0.05, to: 0.05).round(6),
    longitude: city_coords[:longitude] + Faker::Number.between(from: -0.05, to: 0.05).round(6)
  }
end

# Générer des coordonnées rurales en Équateur
def rural_coordinates
  {
    latitude: Faker::Number.between(from: -4.0, to: 2.0).round(6),
    longitude: Faker::Number.between(from: -81.0, to: -75.0).round(6)
  }
end

# Liste des utilisateurs pour éviter les nil
user_ids = User.pluck(:id)

# Créer des incidents (300 au total, 80% en ville, 20% à la campagne, 80% terminés)
puts "Création de 300 incidents (240 en ville, 60 en campagne, 80% terminés)..."
240.times do # Incidents en ville (80%)
  city_name, city_coords = cities.to_a.sample
  coords = city_coordinates(city_coords)
  status = rand < 0.8 ? false : true # 80% terminés
  incident = Incident.create!(
    title: "#{categories.sample} à #{city_name}",
    description: Faker::Lorem.paragraph(sentence_count: 2),
    address: "#{Faker::Address.street_address}, #{city_name}",
    status: status,
    category: categories.sample,
    user_id: user_ids.sample,
    photo_url: Faker::LoremFlickr.image(size: "300x300", search_terms: ['crime', 'disaster']),
    latitude: coords[:latitude],
    longitude: coords[:longitude],
    vote_count_plus: Faker::Number.between(from: 0, to: 20),
    vote_count_minus: Faker::Number.between(from: 0, to: 10),
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 6.months.ago, to: Time.now)
  )

  # Ajouter des votes (max 30 utilisateurs différents par incident)
  available_users = user_ids.shuffle[0..29]
  votes_plus = [incident.vote_count_plus, available_users.size].min
  votes_minus = [incident.vote_count_minus, available_users.size - votes_plus].min

  votes_plus.times do
    Vote.create!(
      vote: true,
      user_id: available_users.shift,
      incident_id: incident.id,
      created_at: incident.created_at,
      updated_at: incident.created_at
    )
  end

  votes_minus.times do
    Vote.create!(
      vote: false,
      user_id: available_users.shift,
      incident_id: incident.id,
      created_at: incident.created_at,
      updated_at: incident.created_at
    )
  end

  # Ajouter des commentaires (1 à 5 par incident)
  rand(1..5).times do
    Comment.create!(
      content: Faker::Lorem.sentence(word_count: 10),
      incident_id: incident.id,
      user_id: user_ids.sample,
      created_at: Faker::Time.between(from: incident.created_at, to: Time.now),
      updated_at: Faker::Time.between(from: incident.created_at, to: Time.now)
    )
  end
end

60.times do # Incidents à la campagne (20%)
  coords = rural_coordinates
  status = rand < 0.8 ? false : true # 80% terminés
  incident = Incident.create!(
    title: "#{categories.sample} en zone rurale",
    description: Faker::Lorem.paragraph(sentence_count: 2),
    address: Faker::Address.full_address,
    status: status,
    category: categories.sample,
    user_id: user_ids.sample,
    photo_url: Faker::LoremFlickr.image(size: "300x300", search_terms: ['crime', 'disaster']),
    latitude: coords[:latitude],
    longitude: coords[:longitude],
    vote_count_plus: Faker::Number.between(from: 0, to: 10),
    vote_count_minus: Faker::Number.between(from: 0, to: 5),
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 6.months.ago, to: Time.now)
  )

  # Ajouter des votes (max 20 utilisateurs différents par incident)
  available_users = user_ids.shuffle[0..19]
  votes_plus = [incident.vote_count_plus, available_users.size].min
  votes_minus = [incident.vote_count_minus, available_users.size - votes_plus].min

  votes_plus.times do
    Vote.create!(
      vote: true,
      user_id: available_users.shift,
      incident_id: incident.id,
      created_at: incident.created_at,
      updated_at: incident.created_at
    )
  end

  votes_minus.times do
    Vote.create!(
      vote: false,
      user_id: available_users.shift,
      incident_id: incident.id,
      created_at: incident.created_at,
      updated_at: incident.created_at
    )
  end

  # Ajouter des commentaires (1 à 3 en campagne)
  rand(1..3).times do
    Comment.create!(
      content: Faker::Lorem.sentence(word_count: 10),
      incident_id: incident.id,
      user_id: user_ids.sample,
      created_at: Faker::Time.between(from: incident.created_at, to: Time.now),
      updated_at: Faker::Time.between(from: incident.created_at, to: Time.now)
    )
  end
end

# Créer des alertes (80% en ville, 20% en campagne)
puts "Création de 100 alertes..."
80.times do # Alertes en ville
  city_name, city_coords = cities.to_a.sample
  coords = city_coordinates(city_coords)
  Alert.create!(
    user_id: user_ids.sample,
    address: "#{Faker::Address.street_address}, #{city_name}",
    latitude: coords[:latitude],
    longitude: coords[:longitude],
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 6.months.ago, to: Time.now)
  )
end

20.times do # Alertes en campagne
  coords = rural_coordinates
  Alert.create!(
    user_id: user_ids.sample,
    address: Faker::Address.full_address,
    latitude: coords[:latitude],
    longitude: coords[:longitude],
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 6.months.ago, to: Time.now)
  )
end

# Créer des notifications avec Geocoder
puts "Création de notifications avec Geocoder..."
Alert.all.each do |alert|
  incidents_nearby = Incident.where(status: false).select do |incident|
    distance = Geocoder::Calculations.distance_between(
      [alert.latitude, alert.longitude],
      [incident.latitude, incident.longitude],
      units: :km
    )
    distance <= 5 # 5 km de rayon
  end

  incidents_nearby.each do |incident|
    Notification.create!(
      user_id: alert.user_id,
      alert_id: alert.id,
      created_at: Faker::Time.between(from: incident.created_at, to: Time.now),
      updated_at: Faker::Time.between(from: incident.created_at, to: Time.now)
    )
  end
end

puts "Seed terminée !"
puts "Utilisateurs: #{User.count}"
puts "Incidents: #{Incident.count} (terminés: #{Incident.where(status: false).count})"
puts "Votes: #{Vote.count}"
puts "Commentaires: #{Comment.count}"
puts "Alertes: #{Alert.count}"
puts "Notifications: #{Notification.count}"

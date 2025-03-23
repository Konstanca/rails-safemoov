require 'faker'
require 'geocoder'

# Mesurer le temps de début
start_time = Time.now
puts "Début du seedage à #{start_time}"

# Définir la locale de Faker en espagnol
Faker::Config.locale = 'es'

# Définir les provinces comme une constante
PROVINCES = [
  "Azuay", "Bolívar", "Cañar", "Carchi", "Chimborazo", "Cotopaxi", "El Oro",
  "Esmeraldas", "Galápagos", "Guayas", "Imbabura", "Loja", "Los Ríos",
  "Manabí", "Morona Santiago", "Napo", "Orellana", "Pastaza", "Pichincha",
  "Santa Elena", "Santo Domingo de los Tsáchilas", "Sucumbíos", "Tungurahua",
  "Zamora Chinchipe"
].freeze

# Réinitialiser les tables dans l’ordre inverse des dépendances
puts "Réinitialisation des tables..."
Vote.destroy_all
Comment.destroy_all
Notification.destroy_all
Incident.destroy_all
Alert.destroy_all
User.destroy_all

# Créer des utilisateurs
puts "Création de 200 utilisateurs..."
200.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

# Liste des catégories d'incidents avec leurs poids
category_weights = {
  "Attaque à main armée" => 5,
  "Assassinat" => 3,
  "Enlèvement" => 3,
  "Prise d’otages" => 2,
  "Éboulement" => 2,
  "Inondation" => 5,
  "Tremblement de terre" => 1,
  "Vol à l’étalage" => 12,
  "Agression" => 10,
  "Trafic de drogue" => 4,
  "Émeute" => 3,
  "Incendie" => 6,
  "Accident de la route" => 15,
  "Fraude électorale" => 1,
  "Manifestation violente" => 3,
  "Disparition" => 2,
  "Braquage de voiture" => 3
}

# Méthode pour sélectionner une catégorie pondérée
def weighted_category(category_weights)
  weighted_array = category_weights.flat_map { |category, weight| [category] * weight }
  weighted_array.sample
end

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

# Générer une adresse urbaine (ex. : "Av. Amazonas y Av. Naciones Unidas, Quito")
def generate_urban_address(city_name)
  street_types = ["Av.", "Calle", "Pasaje"]
  street_names = [
    "Amazonas", "Naciones Unidas", "10 de Agosto", "Shyris", "Colón",
    "6 de Diciembre", "Eloy Alfaro", "República", "Mariana de Jesús",
    "La Prensa", "Los Álamos", "De los Pinos", "La Rábida", "San Ignacio",
    "González Suárez", "De las Palmeras", "De los Cipreses", "La Coruña",
    "De los Laureles", "Simón Bolívar"
  ]
  street1 = "#{street_types.sample} #{street_names.sample}"
  street2 = "#{street_types.sample} #{street_names.sample}"
  "#{street1} y #{street2}, #{city_name}"
end

# Générer une adresse rurale (ex. : "Sector La Esperanza, Provincia de Imbabura")
def generate_rural_address
  sectors = [
    "La Esperanza", "San Rafael", "El Progreso", "La Libertad", "Santa Rosa",
    "El Porvenir", "San Antonio", "La Victoria", "El Carmen", "San José",
    "La Merced", "El Triunfo", "San Miguel", "La Paz", "San Pedro",
    "Santa Ana", "San Francisco", "La Unión", "El Rosario", "San Isidro"
  ]
  "Sector #{sectors.sample}, Provincia de #{PROVINCES.sample}"
end

# Générer une description d'incident réaliste
def generate_incident_description(category)
  case category
  when "Attaque à main armée"
    "Un groupe armé a attaqué #{Faker::Company.name} près de #{Faker::Address.street_name}. Les assaillants ont pris la fuite avec #{Faker::Number.between(from: 1000, to: 10000)} dollars."
  when "Assassinat"
    "Un assassinat a eu lieu dans un quartier résidentiel. La victime, #{Faker::Name.name}, a été retrouvée près de #{Faker::Address.street_name}."
  when "Enlèvement"
    "Un enlèvement a été signalé : #{Faker::Name.name} a été vu pour la dernière fois près de #{Faker::Address.street_name}."
  when "Prise d’otages"
    "Une prise d’otages est en cours dans un bâtiment de #{Faker::Company.name}. Les forces de l’ordre sont sur place."
  when "Éboulement"
    "Un éboulement a bloqué la route principale près de #{Faker::Address.street_name}, causant des dégâts matériels."
  when "Inondation"
    "Une inondation a submergé plusieurs maisons dans la région de #{Faker::Address.street_name}. Les secours sont en route."
  when "Tremblement de terre"
    "Un tremblement de terre de magnitude #{Faker::Number.between(from: 3, to: 7)}.#{Faker::Number.between(from: 0, to: 9)} a frappé la région, causant des dégâts."
  when "Vol à l’étalage"
    "Un vol à l’étalage a été signalé dans un magasin de #{Faker::Company.name}. Le suspect a pris des biens d’une valeur de #{Faker::Number.between(from: 50, to: 500)} dollars."
  when "Agression"
    "Une agression violente a eu lieu près de #{Faker::Address.street_name}. La victime a été transportée à l’hôpital."
  when "Trafic de drogue"
    "Les autorités ont démantelé un réseau de trafic de drogue opérant près de #{Faker::Address.street_name}."
  when "Émeute"
    "Une émeute a éclaté lors d’une manifestation, causant des affrontements près de #{Faker::Address.street_name}."
  when "Incendie"
    "Un incendie s’est déclaré dans un immeuble près de #{Faker::Address.street_name}. Les pompiers sont sur place."
  when "Accident de la route"
    "Un accident de la route impliquant #{Faker::Number.between(from: 2, to: 5)} véhicules a eu lieu sur #{Faker::Address.street_name}."
  when "Fraude électorale"
    "Des soupçons de fraude électorale ont été signalés lors des élections locales dans la région de #{Faker::Address.street_name}."
  when "Manifestation violente"
    "Une manifestation violente a dégénéré près de #{Faker::Address.street_name}, causant plusieurs blessés."
  else
    "Un incident de type #{category} a été signalé près de #{Faker::Address.street_name}."
  end
end

# Générer un commentaire réaliste
def generate_comment(category)
  reactions = [
    "C’est vraiment inquiétant, il faut plus de sécurité dans ce quartier !",
    "J’ai vu ça de mes propres yeux, c’était terrifiant.",
    "Les autorités doivent agir rapidement pour éviter que ça se reproduise.",
    "Quelqu’un a des nouvelles des victimes ?",
    "C’est la troisième fois ce mois-ci, c’est inacceptable !",
    "J’espère que les coupables seront arrêtés bientôt.",
    "Il faut organiser une réunion communautaire pour discuter de ça.",
    "Je passe par là tous les jours, ça aurait pu être moi…",
    "Les secours ont mis trop de temps à arriver, c’est scandaleux !",
    "Quelqu’un sait si la route est encore bloquée ?"
  ]
  reactions.sample
end


# Liste des utilisateurs pour éviter les nil
user_ids = User.pluck(:id)

# Créer des incidents (4 000 au total, 80% en ville, 20% à la campagne, 80% terminés)
puts "Création de 1800 incidents (1500 en ville, 300 en campagne, 80% terminés)..."
1500.times do # Incidents en ville (80%)
  city_name, city_coords = cities.to_a.sample
  coords = city_coordinates(city_coords)
  status = rand < 0.8 ? false : true # 80% terminés
  category = weighted_category(category_weights)
  incident = Incident.create!(
    title: "#{category} à #{city_name}",
    description: generate_incident_description(category),
    address: generate_urban_address(city_name),
    status: status,
    category: category,
    user_id: user_ids.sample,

    latitude: coords[:latitude],
    longitude: coords[:longitude],
    vote_count_plus: Faker::Number.between(from: 0, to: 20),
    vote_count_minus: Faker::Number.between(from: 0, to: 10),
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
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

  # Ajouter des commentaires (1 à 3 par incident)
  rand(1..3).times do
    Comment.create!(
      content: generate_comment(category),
      incident_id: incident.id,
      user_id: user_ids.sample,
      created_at: Faker::Time.between(from: incident.created_at, to: Time.now),
      updated_at: Faker::Time.between(from: incident.created_at, to: Time.now)
    )
  end
end

300.times do # Incidents à la campagne (20%)
  coords = rural_coordinates
  status = rand < 0.8 ? false : true # 80% terminés
  category = weighted_category(category_weights)
  incident = Incident.create!(
    title: "#{category} en zone rurale",
    description: generate_incident_description(category),
    address: generate_rural_address,
    status: status,
    category: category,
    user_id: user_ids.sample,

    latitude: coords[:latitude],
    longitude: coords[:longitude],
    vote_count_plus: Faker::Number.between(from: 0, to: 10),
    vote_count_minus: Faker::Number.between(from: 0, to: 5),
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
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
      content: generate_comment(category),
      incident_id: incident.id,
      user_id: user_ids.sample,
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
puts "Notifications: #{Notification.count}"

# Vérifier la répartition des catégories
puts "Répartition des incidents par catégorie :"
Incident.group(:category).count.each do |category, count|
  puts "#{category}: #{count} (#{((count.to_f / Incident.count) * 100).round(2)}%)"
end

# Mesurer le temps de fin et calculer la durée
end_time = Time.now
execution_time = end_time - start_time
puts "Seedage terminé en #{execution_time.round(2)} secondes (#{execution_time.round(2) / 60} minutes)."

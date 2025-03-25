# Charger l'environnement Rails
require File.expand_path('../config/environment', __dir__)

# Charger Faker avec la locale espagnole
require 'faker'
Faker::Config.locale = 'es'

start_time = Time.now
puts "Début du seedage à #{start_time}"

PROVINCES = %w[
  Azuay Bolívar Cañar Carchi Chimborazo Cotopaxi El\ Oro Esmeraldas Galápagos Guayas Imbabura Loja Los\ Ríos
  Manabí Morona\ Santiago Napo Orellana Pastaza Pichincha Santa\ Elena Santo\ Domingo\ de\ los\ Tsáchilas Sucumbíos
  Tungurahua Zamora\ Chinchipe
].freeze

# Polygone simplifié de l'Équateur continental
ECUADOR_POLYGON = [
  [-0.8, -75.3],  # Nord-Est (près du tripoint Colombie/Pérou)
  [0.8, -75.5],   # Nord-Est (frontière Colombie, près de Putumayo)
  [1.0, -77.0],   # Nord (près de Tulcán)
  [1.4, -78.9],   # Nord-Ouest (incluant San Lorenzo, près de Esmeraldas)
  [-0.5, -80.5],  # Ouest (côte près de Esmeraldas)
  [-1.5, -80.8],  # Sud-Ouest (côte près de Manta)
  [-3.0, -80.3],  # Sud-Ouest (près de Machala)
  [-4.0, -79.5],  # Sud (frontière Pérou, près de Loja)
  [-3.5, -78.0],  # Sud-Est (Amazonie, près de Zamora)
  [-2.0, -76.0],  # Est (Amazonie, près de Puyo)
  [-0.8, -75.3]   # Retour au point de départ
].freeze

# Bounding box réduite pour optimisation
ECUADOR_BOUNDS = {
  min_lat: -4.0, max_lat: 0.8,
  min_lon: -80.8, max_lon: -75.2
}.freeze

def point_in_polygon?(lat, lon, polygon)
  inside = false
  polygon.each_cons(2) do |(x1, y1), (x2, y2)|
    if ((y1 > lon) != (y2 > lon)) && (lat < (x2 - x1) * (lon - y1) / (y2 - y1) + x1)
      inside = !inside
    end
  end
  inside
end

def weighted_category(category_weights)
  weighted_array = category_weights.flat_map { |category, weight| [category] * weight }
  weighted_array.sample
end

def city_coordinates(city_coords)
  attempts = 0
  max_attempts = 100
  loop do
    attempts += 1
    lat = city_coords[:latitude] + Faker::Number.between(from: -0.05, to: 0.05).round(6)
    lon = city_coords[:longitude] + Faker::Number.between(from: -0.05, to: 0.05).round(6)
    coords = { latitude: lat, longitude: lon }
    if point_in_polygon?(lat, lon, ECUADOR_POLYGON)
      puts "Coordonnées valides trouvées pour ville après #{attempts} tentatives : #{lat}, #{lon}"
      return coords
    end
    if attempts >= max_attempts
      puts "Échec après #{max_attempts} tentatives, retour aux coordonnées de base : #{city_coords[:latitude]}, #{city_coords[:longitude]}"
      return city_coords # Retour aux coordonnées de base si échec
    end
  end
end

def rural_coordinates
  attempts = 0
  max_attempts = 100
  loop do
    attempts += 1
    lat = Faker::Number.between(from: ECUADOR_BOUNDS[:min_lat], to: ECUADOR_BOUNDS[:max_lat]).round(6)
    lon = Faker::Number.between(from: ECUADOR_BOUNDS[:min_lon], to: ECUADOR_BOUNDS[:max_lon]).round(6)
    coords = { latitude: lat, longitude: lon }
    if point_in_polygon?(lat, lon, ECUADOR_POLYGON)
      puts "Coordonnées valides trouvées pour rural après #{attempts} tentatives : #{lat}, #{lon}"
      return coords
    end
    if attempts >= max_attempts
      puts "Échec après #{max_attempts} tentatives, coordonnées par défaut : -0.5, -78.0"
      return { latitude: -0.5, longitude: -78.0 } # Point central comme fallback
    end
  end
end

def generate_urban_address(city_name)
  street_types = ["Av.", "Calle", "Pasaje"]
  street1 = "#{street_types.sample} #{Faker::Address.street_name}"
  street2 = "#{street_types.sample} #{Faker::Address.street_name}"
  "#{street1} y #{street2}, #{city_name}"
end

def generate_rural_address
  sectors = ["La Esperanza", "San Rafael", "El Progreso", "La Libertad", "Santa Rosa"]
  "Sector #{sectors.sample}, Provincia de #{PROVINCES.sample}"
end

def generate_incident_description(category)
  case category
  when "Attaque à main armée" then "Un groupe armé a attaqué #{Faker::Company.name} près de #{Faker::Address.street_name}. Les assaillants ont pris la fuite avec #{Faker::Number.between(from: 1000, to: 10000)} dollars."
  when "Assassinat" then "Un assassinat a eu lieu dans un quartier résidentiel. La victime, #{Faker::Name.name}, a été retrouvée près de #{Faker::Address.street_name}."
  when "Enlèvement" then "Un enlèvement a été signalé : #{Faker::Name.name} a été vu pour la dernière fois près de #{Faker::Address.street_name}."
  when "Prise d’otages" then "Une prise d’otages est en cours dans un bâtiment de #{Faker::Company.name}. Les forces de l’ordre sont sur comptes."
  when "Éboulement" then "Un éboulement a bloqué la route principale près de #{Faker::Address.street_name}, causant des dégâts matériels."
  when "Inondation" then "Une inondation a submergé plusieurs maisons dans la région de #{Faker::Address.street_name}. Les secours sont en route."
  when "Tremblement de terre" then "Un tremblement de terre de magnitude #{Faker::Number.between(from: 3, to: 7)}.#{Faker::Number.between(from: 0, to: 9)} a frappé la région, causant des dégâts."
  when "Vol à l’étalage" then "Un vol à l’étalage a été signalé dans un magasin de #{Faker::Company.name}. Le suspect a pris des biens d’une valeur de #{Faker::Number.between(from: 50, to: 500)} dollars."
  when "Agression" then "Une agression violente a eu lieu près de #{Faker::Address.street_name}. La victime a été transportée à l’hôpital."
  when "Trafic de drogue" then "Les autorités ont démantelé un réseau de trafic de drogue opérant près de #{Faker::Address.street_name}."
  when "Émeute" then "Une émeute a éclaté lors d’une manifestation, causant des affrontements près de #{Faker::Address.street_name}."
  when "Incendie" then "Un incendie s’est déclaré dans un immeuble près de #{Faker::Address.street_name}. Les pompiers sont sur place."
  when "Accident de la route" then "Un accident de la route impliquant #{Faker::Number.between(from: 2, to: 5)} véhicules a eu lieu sur #{Faker::Address.street_name}."
  when "Fraude électorale" then "Des soupçons de fraude électorale ont été signalés lors des élections locales dans la région de #{Faker::Address.street_name}."
  when "Manifestation violente" then "Une manifestation violente a dégénéré près de #{Faker::Address.street_name}, causant plusieurs blessés."
  else "Un incident de type #{category} a été signalé près de #{Faker::Address.street_name}."
  end
end

def generate_comment(category)
  reactions = [
    "C’est vraiment inquiétant, il faut plus de sécurité dans ce quartier !",
    "J’ai vu ça de mes propres yeux, c’était terrifiant.",
    "Les autorités doivent agir rapidement pour éviter que ça se reproduise.",
    "Quelqu’un a des nouvelles des victimes ?",
    "C’est la troisième fois ce mois-ci, c’est inacceptable !"
  ]
  reactions.sample
end

puts "Réinitialisation des tables..."
Vote.destroy_all
Comment.destroy_all
Notification.destroy_all
Incident.destroy_all
Alert.destroy_all
User.destroy_all

# Désactiver les callbacks coûteux
Incident.skip_callback(:validation, :after, :geocode)
Incident.skip_callback(:create, :after)

ActiveRecord::Base.transaction do
  puts "Création de 50 utilisateurs avec nicknames..."
  50.times do |i|
    user = User.create!(
      email: Faker::Internet.unique.email,
      password: "password123",
      nickname: Faker::Internet.unique.username(specifier: 5..10), # Génère un pseudo unique de 5 à 10 caractères
      created_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
    )
    puts "Utilisateur #{i + 1} créé : #{user.email} (Nickname: #{user.nickname})"
  end

  user_ids = User.pluck(:id)
  puts "Création de 1200 incidents (1000 en ville, 200 en campagne)..."

  cities = {
    "Quito" => { latitude: -0.1807, longitude: -78.4678 }, "Guayaquil" => { latitude: -2.1894, longitude: -79.8891 },
    "Cuenca" => { latitude: -2.9005, longitude: -79.0045 }, "Santo Domingo" => { latitude: -0.2532, longitude: -79.1719 },
    "Machala" => { latitude: -3.2586, longitude: -79.9554 }, "Manta" => { latitude: -0.9677, longitude: -80.7089 },
    "Portoviejo" => { latitude: -1.0546, longitude: -80.4525 }, "Ambato" => { latitude: -1.2417, longitude: -78.6198 },
    "Riobamba" => { latitude: -1.6710, longitude: -78.6483 }, "Loja" => { latitude: -3.9931, longitude: -79.2042 }
  }

  category_weights = {
    "Attaque à main armée" => 5, "Assassinat" => 3, "Enlèvement" => 3, "Prise d’otages" => 2, "Éboulement" => 2,
    "Inondation" => 5, "Tremblement de terre" => 1, "Vol à l’étalage" => 12, "Agression" => 10, "Trafic de drogue" => 4,
    "Émeute" => 3, "Incendie" => 6, "Accident de la route" => 15, "Fraude électorale" => 1, "Manifestation violente" => 3,
    "Disparition" => 2, "Braquage de voiture" => 3
  }

  # Incidents urbains (1000)
  1000.times do |i|
    puts "Début incident urbain #{i + 1}"
    city_name, city_coords = cities.to_a.sample
    coords = city_coordinates(city_coords)
    status = rand < 0.8 ? false : true
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
      created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
      updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
    )
    puts "Incident #{i + 1} créé : #{incident.title}"

    available_users = user_ids.shuffle[0..29]
    votes_plus = Faker::Number.between(from: 0, to: 20)
    votes_minus = Faker::Number.between(from: 0, to: 10)

    votes_plus.times do
      Vote.create!(
        vote: true,
        user_id: available_users.shift,
        incident_id: incident.id,
        created_at: incident.created_at,
        updated_at: incident.created_at
      )
    end
    puts "Votes positifs ajoutés pour incident #{i + 1}: #{votes_plus}"

    votes_minus.times do
      Vote.create!(
        vote: false,
        user_id: available_users.shift,
        incident_id: incident.id,
        created_at: incident.created_at,
        updated_at: incident.created_at
      )
    end
    puts "Votes négatifs ajoutés pour incident #{i + 1}: #{votes_minus}"

    rand(1..3).times do
      Comment.create!(
        content: generate_comment(category),
        incident_id: incident.id,
        user_id: user_ids.sample,
        created_at: Faker::Time.between(from: incident.created_at, to: Time.now),
        updated_at: Faker::Time.between(from: incident.created_at, to: Time.now)
      )
    end
    puts "Commentaires ajoutés pour incident #{i + 1}"

    puts "#{i + 1} incidents urbains créés" if (i + 1) % 10 == 0
  end

  # Incidents ruraux (200)
  200.times do |i|
    puts "Début incident rural #{i + 1}"
    coords = rural_coordinates
    status = rand < 0.8 ? false : true
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
      created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
      updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
    )
    puts "Incident rural #{i + 1} créé : #{incident.title}"

    available_users = user_ids.shuffle[0..19]
    votes_plus = Faker::Number.between(from: 0, to: 10)
    votes_minus = Faker::Number.between(from: 0, to: 5)

    votes_plus.times do
      Vote.create!(
        vote: true,
        user_id: available_users.shift,
        incident_id: incident.id,
        created_at: incident.created_at,
        updated_at: incident.created_at
      )
    end
    puts "Votes positifs ajoutés pour incident rural #{i + 1}: #{votes_plus}"

    votes_minus.times do
      Vote.create!(
        vote: false,
        user_id: available_users.shift,
        incident_id: incident.id,
        created_at: incident.created_at,
        updated_at: incident.created_at
      )
    end
    puts "Votes négatifs ajoutés pour incident rural #{i + 1}: #{votes_minus}"

    rand(1..3).times do
      Comment.create!(
        content: generate_comment(category),
        incident_id: incident.id,
        user_id: user_ids.sample,
        created_at: Faker::Time.between(from: incident.created_at, to: Time.now),
        updated_at: Faker::Time.between(from: incident.created_at, to: Time.now)
      )
    end
    puts "Commentaires ajoutés pour incident rural #{i + 1}"

    puts "#{i + 1} incidents ruraux créés" if (i + 1) % 10 == 0
  end
end

# Réactiver les callbacks si nécessaire
Incident.set_callback(:validation, :after, :geocode)
Incident.set_callback(:create, :after, :trigger_notifications)

puts "Seed terminée !"
puts "Utilisateurs: #{User.count}"
puts "Incidents: #{Incident.count} (terminés: #{Incident.where(status: false).count})"
puts "Votes: #{Vote.count}"
puts "Commentaires: #{Comment.count}"

end_time = Time.now
execution_time = end_time - start_time
puts "Seedage terminé en #{execution_time.round(2)} secondes."

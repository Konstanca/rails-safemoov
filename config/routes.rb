Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"


  get "statistics/local/:incident_id", to: "statistics#local", as: :local_statistics

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

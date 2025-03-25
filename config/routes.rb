Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :incidents, only: [:show, :index, :new, :create, :edit, :update, :destroy] do
    collection do
      get :my_incidents
    end
    member do
      post :confirm
      post :contest
    end
  end
 # get 'incidents/my_incidents', to: 'incidents#my_incidents'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :alerts, only: [:index]

  get "statistics/local/:incident_id", to: "statistics#local", as: :local_statistics

  get "up" => "rails/health#show", as: :rails_health_check
  # Defines the root path route ("/")
  # root "posts#index"
end

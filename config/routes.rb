Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :incidents, only: [:show, :index, :new, :create, :edit, :update, :destroy] do
    member do
      get :info_window
    end
    resources :comments, only: [:create]
    collection do
      get :my_incidents
    end
    member do
      post :confirm
      post :contest
    end
  end

  resources :comments, only: [:index]

  resources :alerts, only: [:index, :new, :create, :destroy, :edit, :update]

  get "statistics/local/:incident_id", to: "statistics#local", as: :local_statistics


  post '/clear_flashes', to: 'application#clear_flashes'

  resources :notifications, only: [] do
    member do
      post :mark_as_read
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  # Defines the root path route ("/")
  # root "posts#index"
end

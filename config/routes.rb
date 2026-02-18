Rails.application.routes.draw do
  # Sessions (login/logout) — only the actions we implement
  resource :session, only: [:new, :create, :destroy]

  # Optional: catch GET /session and redirect to login page
  # Prevents "No route matches [GET] '/session'" on reload or non-JS logout
  get "/session" => redirect("/session/new")

  resources :passwords, param: :token

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "arts#index"

  # Arts and subscribers
  resources :arts, except: [:new, :create] do
    resources :subscribers, only: [:create]
  end

  # Unsubscribe
  resource :unsubscribe, only: [:show]

  # External Met Museum integration
  get "art/random" => "external_arts#random"

  # User registration
  resources :users, only: [:new, :create]

  # Subscribe/unsubscribe to Met objects
  post "art/:object_id/subscribe" => "met_subscriptions#create", as: :met_subscriptions
  delete "art/:object_id/unsubscribe" => "met_subscriptions#destroy", as: :met_unsubscribe
end

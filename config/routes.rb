Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "arts#index"

  resources :arts, except: [ :new, :create ] do
    resources :subscribers, only: [ :create ]
  end
  resource :unsubscribe, only: [ :show ]

  # External Met Museum integration
  get "art/random" => "external_arts#random"

  # Fetch met object JSON for modal display (removed)

  # User registration
  resources :users, only: [ :new, :create ]

  # Subscribe/unsubscribe to Met objects (authenticated users only)
  post "art/:object_id/subscribe" => "met_subscriptions#create", as: :met_subscriptions
  delete "art/:object_id/unsubscribe" => "met_subscriptions#destroy", as: :met_unsubscribe
end

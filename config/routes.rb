Rails.application.routes.draw do
  get "libcoin_transactions/index"
  get "dashboard/index"
  get "home/index"
  get "images/index"
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  get "errors/access_denied", to: "errors#access_denied", as: "access_denied"
  delete "logout", to: "application#sign_out_current_user", as: "logout"
  resources :out_of_context, only: [ :index, :destroy ]
  resources :libcoin_transactions, only: [ :index ]
  resources :high_rollers, only: [ :index ]

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
end

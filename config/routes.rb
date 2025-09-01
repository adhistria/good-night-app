Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :follows, only: [:create]
      delete 'follows/:following_id', to: 'follows#destroy', as: :unfollow_user

      post "/clock_in", to: "sleep_records#clock_in"
      patch "/clock_out/:id", to: "sleep_records#clock_out"

      get "/sleep_records", to: "sleep_records#index"

      # resources :sleep_records, only: [:index] do
      #   collection do
      #     post :clock_in
      #     post :clock_out
      #   end
      # end

    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end

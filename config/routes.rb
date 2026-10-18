Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :staff_api, path: "staff-api" do
    namespace :v1 do
      resources :editions, only: [] do
        resources :books, only: :create
      end

      resources :books, only: %i[ index show destroy ], param: :sku do
        scope module: :books do
          resources :loans, only: :create
          resource :return, only: :create
        end
      end
    end
  end

  namespace :public_api, path: "public-api" do
    namespace :v1 do
      resources :books, only: :index
    end
  end
end

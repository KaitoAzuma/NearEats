Rails.application.routes.draw do
  resources :bookmarks
  resources :bookmarks, except: [:new, :edit, :update, :destroy]
  resources :comments
  devise_for :users
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "restaurants#search"

  get "restaurants/search", to: "restaurants#search"
  get "restaurants/result", to: "restaurants#result"
  get "restaurants/show", to: "restaurants#show"
  get "restaurants/ex", to: "restaurants#ex"
  delete "bookmarks/destroy", to: "restaurants#destroy"
end

Rails.application.routes.draw do
  get "example", to: "home#index"

  resources :contacts

  mount Aeno::Engine => "/"
end

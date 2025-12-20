Aeno::Engine.routes.draw do
  root "showcase#index"
  get "showcase/:id", to: "showcase#show", as: :showcase

  namespace :examples do
    resources :contacts
  end
end

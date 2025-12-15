Aeno::Engine.routes.draw do
  get("/showcase/:namespace/:id", to: "showcase#show", as: :showcase_component)
  patch("/theme", to: "theme#update", as: :theme)
  root(to: "showcase#index")
end

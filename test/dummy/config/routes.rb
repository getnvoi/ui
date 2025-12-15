Rails.application.routes.draw do
  mount Aeno::Engine => "/"

  # root to: "components#index"

  # # Base (cornerstones with live theming)
  # get "base/:id", to: "components#show", as: :base_component

  # # Primitives (CSS modules components)
  # get "primitives/:id", to: "primitives#show", as: :primitive

  # # Blocks (composite components)
  # get "blocks/:id", to: "blocks#show", as: :block_component

  # # Legacy support
  # get "components/:id", to: redirect("/base/%{id}")
end

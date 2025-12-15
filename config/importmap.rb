pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "aeno/application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Floating UI
pin "@floating-ui/core", to: "https://cdn.jsdelivr.net/npm/@floating-ui/core@1.6.9/+esm"
pin "@floating-ui/utils", to: "https://cdn.jsdelivr.net/npm/@floating-ui/utils@0.2.9/+esm"
pin "@floating-ui/dom", to: "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.6.13/+esm"

pin_all_from(
  Aeno::Engine.root.join("app/javascript/aeno/controllers"),
  under: "aeno/controllers",
)

pin_all_from(
  Aeno::Engine.root.join("app/components/aeno"),
  under: "aeno/components",
  to: "aeno"
)

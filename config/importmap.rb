pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "aeros/application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin_all_from(
  Aeros::Engine.root.join("app/javascript/aeros/controllers"),
  under: "aeros/controllers",
)

pin_all_from(
  Aeros::Engine.root.join("app/components/aeros"),
  under: "aeros/components",
  to: "aeros"
)

module Aeno::Primitives::InputPassword
  class Component < ::Aeno::FormBuilder::BaseComponent
    prop :autocomplete, description: "Autocomplete attribute", default: -> { "current-password" }
    prop :show_toggle, description: "Show password visibility toggle", default: -> { true }

    examples("Input Password", description: "Password input with visibility toggle") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "password"
      end

      b.example(:with_label, title: "With Label") do |e|
        e.preview name: "password", label: "Password"
      end

      b.example(:no_toggle, title: "Without Toggle") do |e|
        e.preview name: "password", show_toggle: false
      end
    end
  end
end

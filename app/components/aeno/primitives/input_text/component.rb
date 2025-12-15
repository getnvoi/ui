module Aeno::Primitives::InputText
  class Component < ::Aeno::FormBuilder::BaseComponent
    prop :autocomplete, description: "Autocomplete attribute", optional: true

    examples("Input Text", description: "Single-line text input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "username"
      end

      b.example(:with_label, title: "With Label") do |e|
        e.preview name: "email", label: "Email", placeholder: "you@example.com"
      end

      b.example(:states, title: "States") do |e|
        e.preview name: "disabled_field", label: "Disabled", disabled: true
        e.preview name: "required_field", label: "Required", required: true
      end
    end
  end
end

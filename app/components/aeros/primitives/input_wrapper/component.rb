module Aeros::Primitives::InputWrapper
  class Component < ::Aeros::ApplicationViewComponent
    prop :label, description: "Input label", optional: true
    prop :name, description: "Input name attribute"
    prop :id, description: "Input id attribute", optional: true
    prop :helper_text, description: "Helper text below input", optional: true
    prop :error_text, description: "Error message", optional: true
    prop :disabled, description: "Disabled state", default: -> { false }
    prop :required, description: "Required field", default: -> { false }

    option(:data, default: proc { {} })

    examples("Input Wrapper", description: "Wrapper for form inputs with label and messages") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "field"
      end

      b.example(:with_label, title: "With Label") do |e|
        e.preview name: "email", label: "Email Address"
      end

      b.example(:with_helper, title: "With Helper Text") do |e|
        e.preview name: "username", label: "Username", helper_text: "Choose a unique username"
      end

      b.example(:with_error, title: "With Error") do |e|
        e.preview name: "email", label: "Email", error_text: "Email is invalid"
      end
    end
  end
end

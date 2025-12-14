module Aeros::Primitives::InputTextArea
  class Component < ::Aeros::FormBuilder::BaseComponent
    prop :rows, description: "Number of visible rows", default: -> { 4 }

    examples("Input Text Area", description: "Multi-line text input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "description"
      end

      b.example(:with_label, title: "With Label") do |e|
        e.preview name: "bio", label: "Bio", placeholder: "Tell us about yourself"
      end

      b.example(:rows, title: "Custom Rows") do |e|
        e.preview name: "content", rows: 8
      end
    end
  end
end

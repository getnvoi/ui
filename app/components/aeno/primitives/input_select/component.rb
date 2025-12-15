module Aeno::Primitives::InputSelect
  class Component < ::Aeno::FormBuilder::BaseComponent
    prop :prompt, description: "Placeholder option", optional: true
    prop :options, description: "Array of [label, value] pairs", default: -> { [] }
    prop :collection, description: "ActiveRecord collection", optional: true
    prop :value_method, description: "Method for option value", optional: true
    prop :label_method, description: "Method for option label", optional: true

    renders_many :select_options, Aeno::Primitives::InputSelect::Option

    examples("Input Select", description: "Dropdown select input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "country", options: [["USA", "us"], ["Canada", "ca"]]
      end

      b.example(:with_prompt, title: "With Prompt") do |e|
        e.preview name: "status", prompt: "Select status...", options: [["Active", "active"], ["Inactive", "inactive"]]
      end
    end
  end
end

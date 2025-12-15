# frozen_string_literal: true

module Aeno::Primitives::InputSlider
  class Component < ::Aeno::ApplicationViewComponent
    prop :name, description: "Input name attribute"
    prop :id, description: "Input id", optional: true
    prop :value, description: "Current value", default: -> { 50 }
    prop :min, description: "Minimum value", default: -> { 0 }
    prop :max, description: "Maximum value", default: -> { 100 }
    prop :step, description: "Step increment", default: -> { 1 }
    prop :label, description: "Label text", optional: true
    prop :show_value, description: "Show current value", default: -> { true }
    prop :helper_text, description: "Helper text", optional: true
    prop :disabled, description: "Disabled state", default: -> { false }
    prop :data, description: "Data attributes", default: -> { {} }

    examples("Input Slider", description: "Range slider input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "volume"
      end

      b.example(:with_label, title: "With Label") do |e|
        e.preview name: "brightness", label: "Brightness", value: 75
      end

      b.example(:custom_range, title: "Custom Range") do |e|
        e.preview name: "temperature", min: -10, max: 40, value: 20, label: "Temperature"
      end
    end

    def input_id
      id || name
    end
  end
end

# frozen_string_literal: true

module Aeno::Primitives::InputColor
  class Component < ::Aeno::ApplicationViewComponent
    prop :name, description: "Input name attribute"
    prop :id, description: "Input id", optional: true
    prop :value, description: "Current color value", default: -> { "#000000" }
    prop :label, description: "Label text", optional: true
    prop :helper_text, description: "Helper text", optional: true
    prop :disabled, description: "Disabled state", default: -> { false }
    prop :data, description: "Data attributes", default: -> { {} }
    prop :size, description: "Size variant", values: [:small, :default, :large], default: -> { :default }

    examples("Input Color", description: "Color picker input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "color"
      end

      b.example(:with_label, title: "With Label") do |e|
        e.preview name: "brand_color", label: "Brand Color", value: "#6366f1"
      end

      b.example(:sizes, title: "Sizes") do |e|
        e.preview name: "small", size: :small
        e.preview name: "default", size: :default
        e.preview name: "large", size: :large
      end
    end

    def input_id
      id || name
    end

    def size_class
      case size.to_sym
      when :small then "cp-input-color--small"
      when :large then "cp-input-color--large"
      else ""
      end
    end
  end
end

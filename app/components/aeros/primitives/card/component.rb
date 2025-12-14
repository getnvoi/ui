module Aeros::Primitives::Card
  class Component < ::Aeros::ApplicationViewComponent
    prop :variant, description: "Card style variant",
         values: [:default, :ghost, :elevated],
         default: -> { :default }
    prop :pad, description: "Padding level (1-4, each = 1rem)", values: [1, 2, 3, 4], optional: true
    prop :centered, description: "Center content with flexbox", default: -> { false }

    examples("Card", description: "Container for grouping related content") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end

      b.example(:variants, title: "Variants", description: "Available style variants") do |e|
        e.preview variant: :default
        e.preview variant: :ghost
        e.preview variant: :elevated
      end

      b.example(:padding, title: "Padding", description: "Padding levels") do |e|
        e.preview pad: 1
        e.preview pad: 2
        e.preview pad: 3
        e.preview pad: 4
      end

      b.example(:centered, title: "Centered", description: "Centered content") do |e|
        e.preview centered: true
      end
    end

    def card_classes
      [
        class_for,
        (class_for(:centered) if centered),
        (class_for(variant) if variant != :default),
        ("pad-#{pad}" if pad),
        css
      ].compact.join(" ")
    end
  end
end

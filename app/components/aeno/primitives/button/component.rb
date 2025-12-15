module Aeno::Primitives::Button
  class Component < ::Aeno::ApplicationViewComponent
    prop :variant, description: "Button style variant",
         values: [:default, :secondary, :destructive, :ghost, :outline, :link],
         default: -> { :default }
    prop :size, description: "Button size",
         values: [:xsmall, :small, :large, :icon],
         optional: true
    prop :label, description: "Button text label", optional: true
    prop :icon, description: "Lucide icon name", optional: true
    prop :href, description: "Link URL (renders as <a>)", optional: true
    prop :disabled, description: "Disable the button", default: -> { false }
    prop :full, description: "Full width button", default: -> { false }

    option(:type, optional: true)
    option(:method, optional: true)
    option(:data, default: -> { {} })
    option(:target, optional: true)

    examples("Button", description: "Clickable actions and navigation links") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview label: "Click me"
      end

      b.example(:variants, title: "Variants", description: "Available style variants") do |e|
        e.preview variant: :default, label: "Default"
        e.preview variant: :secondary, label: "Secondary"
        e.preview variant: :destructive, label: "Destructive"
        e.preview variant: :outline, label: "Outline"
        e.preview variant: :ghost, label: "Ghost"
        e.preview variant: :link, label: "Link"
      end

      b.example(:sizes, title: "Sizes", description: "Available sizes") do |e|
        e.preview size: :xsmall, label: "XSmall"
        e.preview size: :small, label: "Small"
        e.preview label: "Default"
        e.preview size: :large, label: "Large"
      end

      b.example(:icons, title: "With Icons", description: "Buttons with icons") do |e|
        e.preview icon: "settings", label: "Settings"
        e.preview icon: "download", label: "Download", variant: :secondary
        e.preview icon: "trash-2", label: "Delete", variant: :destructive
        e.preview icon: "settings", size: :icon
      end

      b.example(:states, title: "States") do |e|
        e.preview label: "Disabled", disabled: true
        e.preview label: "Full Width", full: true
      end
    end

    def button_classes
      classes(variant:, size:, disabled:, full:)
    end

    def call
      action_tag(href:, method:, data: merged_data, class: button_classes, target:, disabled:) do
        (icon ? lucide_icon(icon, class: "flex-shrink-0 icon") : "".html_safe) +
          ui("spinner", size: :sm, variant: :white, css: "spinner hidden") +
          (label ? content_tag(:span, label, class: "truncate flex-shrink") : "".html_safe)
      end
    end
  end
end

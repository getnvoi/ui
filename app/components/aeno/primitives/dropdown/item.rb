module Aeno::Primitives::Dropdown
  class Item < ::Aeno::ApplicationViewComponent
    option :href, optional: true
    option :method, optional: true
    option :icon, optional: true
    option :shortcut, optional: true
    option :disabled, default: -> { false }
    option :data, default: -> { {} }
    option :form_data, default: -> { {} }

    def item_classes
      classes = ["cp-dropdown__item"]
      classes << "cp-dropdown__item--disabled" if disabled
      classes.join(" ")
    end

    def item_data
      data.merge("action" => "click->aeno--primitives--dropdown#select")
    end

    def call
      action_tag(href:, method:, data: item_data, form_data:, class: item_classes, role: "menuitem", disabled:) do
        (icon ? lucide_icon(icon, class: "cp-dropdown__item-icon") : "".html_safe) +
          content_tag(:span, content, class: "cp-dropdown__item-label") +
          (shortcut ? content_tag(:span, shortcut, class: "cp-dropdown__item-shortcut") : "".html_safe)
      end
    end
  end
end

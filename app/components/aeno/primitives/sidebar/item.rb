module Aeno::Primitives::Sidebar
  class Item < Aeno::ApplicationViewComponent
    option :label
    option :href
    option :icon, optional: true
    option :active, default: proc { false }

    def item_classes
      ["cp-sidebar__item", active ? "cp-sidebar__item--active" : nil, css].compact.join(" ")
    end

    erb_template <<~ERB
      <%= link_to(href, class: item_classes) do %>
        <%= lucide_icon(icon) if icon %>
        <span><%= label %></span>
      <% end %>
    ERB
  end
end

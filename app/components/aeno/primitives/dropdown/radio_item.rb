module Aeno::Primitives::Dropdown
  class RadioItem < ::Aeno::ApplicationViewComponent
    option :name
    option :value
    option :checked, default: -> { false }
    option :icon, optional: true

    erb_template <<~ERB
      <button type="button"
              class="cp-dropdown__item cp-dropdown__item--radio"
              role="menuitemradio"
              aria-checked="<%= checked %>"
              data-action="click->aeno--primitives--dropdown#selectRadio"
              data-name="<%= name %>"
              data-value="<%= value %>">
        <span class="cp-dropdown__item-check">
          <% if checked %><%= lucide_icon("check", class: "cp-dropdown__check-icon") %><% end %>
        </span>
        <% if icon %><%= lucide_icon(icon, class: "cp-dropdown__item-icon") %><% end %>
        <span class="cp-dropdown__item-label"><%= content %></span>
      </button>
    ERB
  end
end

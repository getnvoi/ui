module Aeno::Examples::Contacts
  class ListItemComponent < ::Aeno::ApplicationViewComponent
    option :contact

    erb_template <<~ERB
      <div id="<%= dom_id(contact) %>" class="p-4 hover:bg-gray-50 transition-colors">
        <div class="flex items-center justify-between">
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-3">
              <div class="flex-shrink-0 w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                <span class="text-blue-600 font-semibold text-sm">
                  <%= contact.name&.first&.upcase || "?" %>
                </span>
              </div>
              <div class="min-w-0">
                <div class="font-semibold text-gray-900 truncate"><%= contact.name %></div>
                <div class="text-sm text-gray-600 truncate"><%= contact.email %></div>
                <% if contact.city.present? || contact.state.present? %>
                  <div class="text-sm text-gray-500">
                    <%= [contact.city, contact.state].compact.join(", ") %>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
          <div class="flex items-center gap-2 ml-4 flex-shrink-0">
            <%= link_to edit_aeno_examples_contact_path(contact),
                data: { turbo_frame: "_top" },
                class: "inline-flex items-center px-3 py-1.5 text-sm text-blue-600 hover:text-blue-900 hover:bg-blue-50 rounded transition-colors" do %>
              <%= lucide_icon("pencil", class: "w-4 h-4 mr-1") %>
              Edit
            <% end %>
            <%= button_to aeno_examples_contact_path(contact),
                method: :delete,
                data: { turbo_confirm: "Are you sure you want to delete this contact?" },
                class: "inline-flex items-center px-3 py-1.5 text-sm text-red-600 hover:text-red-900 hover:bg-red-50 rounded transition-colors" do %>
              <%= lucide_icon("trash-2", class: "w-4 h-4 mr-1") %>
              Delete
            <% end %>
          </div>
        </div>
      </div>
    ERB
  end
end

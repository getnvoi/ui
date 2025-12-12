module Aeros::Dropdown
  class Component < ::Aeros::ApplicationViewComponent
    option(:css, optional: true)
    option(:label, optional: true)
    option(:button_variant, default: proc { :white })
    option(:button_size, default: proc { :small })
    option(:searchable, default: proc { false })
    option(:placeholder, default: proc { "Search..." })
    option(:empty_message, default: proc { "No results found." })

    renders_many :options, "OptionComponent"
    renders_many :groups, "GroupComponent"

    class OptionComponent < ApplicationViewComponent
      option(:value)
      option(:label)
      option(:href, optional: true)
      option(:selected, default: proc { false })
      option(:icon, optional: true)

      style do
        base do
          %w[
            block w-full text-left px-4 py-2 text-sm text-gray-700
            hover:bg-gray-100 hover:text-gray-900
            cursor-pointer
          ]
        end

        variants do
          selected do
            yes { "bg-gray-50" }
          end
        end
      end

      def classes
        style(selected:)
      end

      erb_template <<~ERB
        <% if href %>
          <a href="<%= href %>"
             class="<%= classes %>"
             role="menuitem"
             data-aeros--dropdown-target="option"
             data-label="<%= label %>"
             data-value="<%= value %>"
             data-action="click->aeros--dropdown#select">
            <div class="flex items-center space-x-2">
              <%= lucide_icon(icon, class: "w-4 h-4") if icon %>
              <span><%= label %></span>
            </div>
          </a>
        <% else %>
          <button type="button"
                  class="<%= classes %>"
                  role="menuitem"
                  data-aeros--dropdown-target="option"
                  data-label="<%= label %>"
                  data-value="<%= value %>"
                  data-action="click->aeros--dropdown#select">
            <div class="flex items-center space-x-2">
              <%= lucide_icon(icon, class: "w-4 h-4") if icon %>
              <span><%= label %></span>
            </div>
          </button>
        <% end %>
      ERB
    end

    class GroupComponent < ApplicationViewComponent
      option(:label)

      renders_many :items, "Aeros::Dropdown::Component::OptionComponent"

      erb_template <<~ERB
        <div class="py-1" data-aeros--dropdown-target="group">
          <div class="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wider">
            <%= label %>
          </div>
          <% items.each do |item| %>
            <%= item %>
          <% end %>
        </div>
      ERB
    end

    def classes
      [
        "relative inline-block text-left",
        css
      ].join(" ")
    end

    def stimulus_data
      {
        controller: "aeros--dropdown",
        "aeros--dropdown-searchable-value": searchable
      }
    end
  end
end

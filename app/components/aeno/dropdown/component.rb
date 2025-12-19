module Aeno::Dropdown
  class Component < ::Aeno::ApplicationViewComponent
    option(:css, optional: true)
    option(:label, optional: true)
    option(:button_variant, default: proc { :white })
    option(:button_size, default: proc { :small })
    option(:searchable, default: proc { false })
    option(:placeholder, default: proc { "Search..." })
    option(:empty_message, default: proc { "No results found." })

    renders_many :options, "OptionComponent"
    renders_many :groups, "GroupComponent"

    class OptionComponent < ::Aeno::ApplicationViewComponent
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
             data-aeno--dropdown-target="option"
             data-label="<%= label %>"
             data-value="<%= value %>"
             data-action="click->aeno--dropdown#select">
            <div class="flex items-center space-x-2">
              <%= lucide_icon(icon, class: "w-4 h-4") if icon %>
              <span><%= label %></span>
            </div>
          </a>
        <% else %>
          <button type="button"
                  class="<%= classes %>"
                  role="menuitem"
                  data-aeno--dropdown-target="option"
                  data-label="<%= label %>"
                  data-value="<%= value %>"
                  data-action="click->aeno--dropdown#select">
            <div class="flex items-center space-x-2">
              <%= lucide_icon(icon, class: "w-4 h-4") if icon %>
              <span><%= label %></span>
            </div>
          </button>
        <% end %>
      ERB
    end

    class GroupComponent < ::Aeno::ApplicationViewComponent
      option(:label)

      renders_many :items, "Aeno::Dropdown::Component::OptionComponent"

      erb_template <<~ERB
        <div class="py-1" data-aeno--dropdown-target="group">
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
        controller: "aeno--dropdown",
        "aeno--dropdown-searchable-value": searchable
      }
    end

    examples("Dropdown", description: "Dropdown menu") do |b|
      b.example(:simple, title: "Simple Flat List") do |e|
        e.preview label: "Options", button_variant: :white, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1")
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
        end
        e.preview label: "Options", button_variant: :default, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1")
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
        end
        e.preview label: "Options", button_variant: :light, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1")
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
        end
        e.preview label: "Options", button_variant: :outline, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1")
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
        end
      end

      b.example(:grouped, title: "Grouped with Headers") do |e|
        e.preview label: "Actions", button_variant: :white, button_size: :small do |dropdown|
          dropdown.with_group(label: "View") do |group|
            group.with_item(value: "list", label: "List View")
            group.with_item(value: "grid", label: "Grid View")
          end
          dropdown.with_group(label: "Actions") do |group|
            group.with_item(value: "edit", label: "Edit")
            group.with_item(value: "delete", label: "Delete")
          end
        end
        e.preview label: "Actions", button_variant: :default, button_size: :small do |dropdown|
          dropdown.with_group(label: "View") do |group|
            group.with_item(value: "list", label: "List View")
            group.with_item(value: "grid", label: "Grid View")
          end
          dropdown.with_group(label: "Actions") do |group|
            group.with_item(value: "edit", label: "Edit")
            group.with_item(value: "delete", label: "Delete")
          end
        end
        e.preview label: "Actions", button_variant: :light, button_size: :small do |dropdown|
          dropdown.with_group(label: "View") do |group|
            group.with_item(value: "list", label: "List View")
            group.with_item(value: "grid", label: "Grid View")
          end
          dropdown.with_group(label: "Actions") do |group|
            group.with_item(value: "edit", label: "Edit")
            group.with_item(value: "delete", label: "Delete")
          end
        end
        e.preview label: "Actions", button_variant: :outline, button_size: :small do |dropdown|
          dropdown.with_group(label: "View") do |group|
            group.with_item(value: "list", label: "List View")
            group.with_item(value: "grid", label: "Grid View")
          end
          dropdown.with_group(label: "Actions") do |group|
            group.with_item(value: "edit", label: "Edit")
            group.with_item(value: "delete", label: "Delete")
          end
        end
      end

      b.example(:icons, title: "With Icons") do |e|
        e.preview label: "Options", button_variant: :white, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Check", icon: "check")
          dropdown.with_option(value: "2", label: "Close", icon: "x")
          dropdown.with_option(value: "3", label: "Circle", icon: "circle")
        end
        e.preview label: "Options", button_variant: :default, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Check", icon: "check")
          dropdown.with_option(value: "2", label: "Close", icon: "x")
          dropdown.with_option(value: "3", label: "Circle", icon: "circle")
        end
        e.preview label: "Options", button_variant: :light, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Check", icon: "check")
          dropdown.with_option(value: "2", label: "Close", icon: "x")
          dropdown.with_option(value: "3", label: "Circle", icon: "circle")
        end
        e.preview label: "Options", button_variant: :outline, button_size: :small do |dropdown|
          dropdown.with_option(value: "1", label: "Check", icon: "check")
          dropdown.with_option(value: "2", label: "Close", icon: "x")
          dropdown.with_option(value: "3", label: "Circle", icon: "circle")
        end
      end

      b.example(:searchable, title: "Selected State + Searchable") do |e|
        e.preview label: "Filter", button_variant: :white, button_size: :small, searchable: true do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1", selected: true)
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
          dropdown.with_option(value: "4", label: "Option 4")
        end
        e.preview label: "Filter", button_variant: :default, button_size: :small, searchable: true do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1", selected: true)
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
          dropdown.with_option(value: "4", label: "Option 4")
        end
        e.preview label: "Filter", button_variant: :light, button_size: :small, searchable: true do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1", selected: true)
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
          dropdown.with_option(value: "4", label: "Option 4")
        end
        e.preview label: "Filter", button_variant: :outline, button_size: :small, searchable: true do |dropdown|
          dropdown.with_option(value: "1", label: "Option 1", selected: true)
          dropdown.with_option(value: "2", label: "Option 2")
          dropdown.with_option(value: "3", label: "Option 3")
          dropdown.with_option(value: "4", label: "Option 4")
        end
      end
    end
  end
end

module Aeno::Drawer
  class ContentComponent < ::Aeno::ApplicationViewComponent
    renders_one(:header)
    renders_one(:footer)
    renders_one :form, lambda { |**options, &block|
      merged_css = [options[:css], FORM_BODY_CLASSES].compact.join(" ")
      Aeno::Form::Component.new(**options.merge(css: merged_css), &block)
    }

    FORM_BODY_CLASSES = [
      "h-full min-h-0 flex flex-col",
      "[&_[data-role='layout']]:h-full",
      "[&_[data-role='layout']]:min-h-0",
      "[&_[data-role='layout']]:flex",
      "[&_[data-role='layout']]:flex-col",
      "[&_[data-role='layout-body']]:h-full",
      "[&_[data-role='layout-body']]:min-h-0",
      "[&_[data-role='layout-body']]:flex",
      "[&_[data-role='layout-body']]:flex-col",
      "[&_[data-role='layout-content']]:flex-1",
      "[&_[data-role='layout-content']]:overflow-y-auto",
      "[&_[data-role='layout-content']]:p-6",
      "[&_[data-role='layout-content']]:space-y-4",
      "[&_[data-role='layout-footer']]:flex-shrink-0",
      "[&_[data-role='layout-footer']]:border-t",
      "[&_[data-role='layout-footer']]:p-4",
      "[&_[data-role='layout-footer']]:flex",
      "[&_[data-role='layout-footer']]:gap-2"
    ].join(" ").freeze

    erb_template <<~ERB
      <% if header %>
        <div class="flex items-center justify-between p-4 border-b flex-shrink-0">
          <div class="flex-1 min-w-0"><%= header %></div>
          <button data-action="click->aeno--drawer#close" type="button"
                  class="ml-4 w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center flex-shrink-0 transition-colors">
            <%= lucide_icon("x", class: "text-gray-500 w-5 h-5") %>
          </button>
        </div>
      <% end %>

      <% if form %>
        <%= form %>
      <% else %>
        <div class="flex-1 overflow-y-auto p-6">
          <%= content %>
        </div>
        <% if footer %>
          <div class="border-t p-4 flex-shrink-0">
            <%= footer %>
          </div>
        <% end %>
      <% end %>
    ERB
  end
end

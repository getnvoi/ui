module Aeros::Drawer
  class Component < ::Aeros::ApplicationViewComponent
    option(:width, default: proc { "w-1/3" })
    option(:id, optional: true)
    option(:standalone, default: proc { false })
    option(:form_submit_close, default: proc { true })

    renders_one(:header)
    renders_one(:trigger)
    renders_one(:footer)

    style(:bg) do
      base { "bg-slate-800/70 fixed inset-0 transition-opacity duration-300 opacity-0 pointer-events-none" }
    end

    style(:wrapper) do
      base { "fixed top-0 right-0 bottom-0 h-full transition-transform duration-300 translate-x-full bg-white shadow-xl" }
    end

    erb_template <<~ERB
      <div data-controller="<%= controller_name %>" id="<%= id %>">
        <% if trigger %>
          <div data-action="click-><%= controller_name %>#open">
            <%= trigger %>
          </div>
        <% end %>

        <% wrapper = -> (&block) { standalone ? capture(&block) : turbo_frame_tag("drawer", &block) } %>
        <%= wrapper.call do %>
          <div data-action="<%= data_actions %>">
            <button
              type="button"
              class="<%= style(:bg) %>"
              data-action="click-><%= controller_name %>#close"
              data-<%= controller_name %>-target="background"
            ></button>
            <div
              class="<%= style(:wrapper) %> <%= width %>"
              data-<%= controller_name %>-target="wrapper"
            >
              <div class="h-screen flex flex-col">
                <% if header %>
                  <div class="flex items-center justify-between p-4 border-b flex-shrink-0">
                    <div class="flex-1 min-w-0"><%= header %></div>
                    <button data-action="click-><%= controller_name %>#close" type="button" class="ml-4 w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center flex-shrink-0 transition-colors">
                      <%= lucide_icon("x", class: "text-gray-500 w-5 h-5") %>
                    </button>
                  </div>
                <% end %>
                <div class="flex-1 overflow-y-auto">
                  <%= content %>
                </div>
                <% if footer %>
                  <div class="border-t p-4 flex-shrink-0">
                    <%= footer %>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    ERB

    private

      def data_actions
        actions = []
        actions << "turbo:frame-load->#{controller_name}#open" unless standalone
        actions << "turbo:submit-end->#{controller_name}#closeOnSubmit" if form_submit_close
        actions.join(" ").presence
      end
  end
end

module Aeno::Drawer
  class Component < ::Aeno::ApplicationViewComponent
    option(:width, default: proc { "w-1/3" })
    option(:id, optional: true)
    option(:standalone, default: proc { false })
    option(:form_submit_close, default: proc { true })

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

    renders_one(:header)
    renders_one(:trigger)
    renders_one(:footer)
    renders_one(:empty, "Aeno::Empty::Component")
    renders_one :form, lambda { |**options, &block|
      merged_css = [options[:css], FORM_BODY_CLASSES].compact.join(" ")
      Aeno::Form::Component.new(**options.merge(css: merged_css), &block)
    }

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
                <% if form %>
                  <%= form %>
                <% else %>
                  <div class="flex-1 overflow-y-auto">
                    <%= empty || content %>
                  </div>
                  <% if footer %>
                    <div class="border-t p-4 flex-shrink-0">
                      <%= footer %>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    ERB

    examples("Drawer", description: "Slide-out panel") do |b|
      b.example(:default, title: "Bare") do |e|
        e.preview standalone: true do |drawer|
          drawer.with_trigger do
            '<button class="px-4 py-2 bg-slate-600 text-white rounded">Open Drawer</button>'.html_safe
          end
          drawer.with_header { "Drawer Title" }
          "Drawer content goes here"
        end
      end

      b.example(:empty, title: "Empty State") do |e|
        e.preview standalone: true do |drawer|
          drawer.with_trigger do
            '<button class="px-4 py-2 bg-slate-600 text-white rounded">Open Empty Drawer</button>'.html_safe
          end
          drawer.with_header { "Documents" }
          drawer.with_empty do |empty|
            empty.with_title { "No documents found" }
            "Upload your first document to get started"
          end
        end
      end

      b.example(:scrollable, title: "Long Scrollable Content") do |e|
        e.preview standalone: true do |drawer|
          drawer.with_trigger do
            '<button class="px-4 py-2 bg-slate-600 text-white rounded">Open Scrollable Drawer</button>'.html_safe
          end
          drawer.with_header { "Terms and Conditions" }
          content = ""
          20.times do |i|
            content += "<h3 class='font-semibold mt-4 mb-2'>Section #{i + 1}</h3>"
            content += "<p class='text-gray-600 mb-2'>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>"
          end
          content.html_safe
        end
      end

      b.example(:iframe, title: "Full Space Iframe") do |e|
        e.preview standalone: true do |drawer|
          drawer.with_trigger do
            '<button class="px-4 py-2 bg-slate-600 text-white rounded">Open Document</button>'.html_safe
          end
          drawer.with_header { "Contract Preview" }
          '<iframe src="https://www.example.com" class="w-full h-full border-0"></iframe>'.html_safe
        end
      end

      b.example(:form, title: "Form with Footer") do |e|
        e.preview standalone: true, form_submit_close: false, width: "w-2/5" do |drawer|
          drawer.with_trigger do
            '<button class="px-4 py-2 bg-slate-600 text-white rounded">Edit Profile</button>'.html_safe
          end
          drawer.with_header { "Edit Profile" }
          drawer.with_form(model: Aeno::Contact.new, url: "/profile") do |form|
            form.with_item_input(type: :text, name: "name", label: "Name")
            form.with_item_input(type: :text, name: "email", label: "Email")
            form.with_item_input(type: :text, name: "city", label: "City")
            form.with_item_input(type: :text, name: "state", label: "State")
            form.with_item_input(type: :text, name: "name", label: "Full Name")
            form.with_item_input(type: :text, name: "email", label: "Email Address")
            form.with_item_input(type: :text, name: "city", label: "City Name")
            form.with_item_input(type: :text, name: "state", label: "State Name")
            form.with_submit(label: "Save", type: "submit")
            form.with_action(label: "Cancel", variant: :secondary, type: "button")
          end
        end
      end

      b.example(:nested, title: "Triple Nested Drawers") do |e|
        e.preview_template standalone: true, template: <<~ERB
          <%= render(Aeno::Drawer::Component.new(standalone: true, width: "w-[700px]")) do |drawer1| %>
            <%= drawer1.with_trigger do %>
              <%= render(Aeno::Button::Component.new(variant: :default, label: "View Documents")) %>
            <% end %>
            <%= drawer1.with_header { "Documents" } %>
            <%= drawer1.with_empty do |empty1| %>
              <%= empty1.with_title { "No documents uploaded yet" } %>
              <p class="text-sm text-gray-600 mb-4">Start by uploading your first document</p>
              <%= render(Aeno::Drawer::Component.new(standalone: true, width: "w-[650px]")) do |drawer2| %>
                <%= drawer2.with_trigger do %>
                  <%= render(Aeno::Button::Component.new(variant: :default, label: "Upload Document")) %>
                <% end %>
                <%= drawer2.with_header { "Upload Document" } %>
                <%= drawer2.with_empty do |empty2| %>
                  <%= empty2.with_title { "Choose upload method" } %>
                  <p class="text-sm text-gray-600 mb-4">Select how you want to upload your document</p>
                  <%= render(Aeno::Drawer::Component.new(standalone: true, width: "w-[600px]")) do |drawer3| %>
                    <%= drawer3.with_trigger do %>
                      <%= render(Aeno::Button::Component.new(variant: :default, label: "Browse Files")) %>
                    <% end %>
                    <%= drawer3.with_header { "File Browser" } %>
                    <%= drawer3.with_empty do |empty3| %>
                      <%= empty3.with_title { "Select a file" } %>
                      <div class="p-6">
                        <div class="border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
                          <%= lucide_icon("upload-cloud", class: "mx-auto h-12 w-12 text-gray-400") %>
                          <p class="mt-2 text-sm text-gray-600">Click to upload or drag and drop</p>
                          <p class="text-xs text-gray-500">PDF, DOC, DOCX up to 10MB</p>
                        </div>
                      </div>
                    <% end %>
                  <% end %>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
        ERB
      end
    end

    private

      def data_actions
        actions = []
        actions << "turbo:frame-load->#{controller_name}#open" unless standalone
        actions << "turbo:submit-end->#{controller_name}#closeOnSubmit" if form_submit_close
        actions.join(" ").presence
      end
  end
end

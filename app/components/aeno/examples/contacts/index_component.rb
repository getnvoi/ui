module Aeno::Examples::Contacts
  class IndexComponent < ::Aeno::ApplicationViewComponent
    option :contacts

    erb_template <<~ERB
      <div class="max-w-4xl mx-auto py-8 px-4">
        <div class="flex items-center justify-between mb-6">
          <h1 class="text-2xl font-bold text-gray-900">Contacts Example</h1>
          <%= link_to "New Contact",
              new_aeno_examples_contact_path,
              data: { turbo_frame: "_top" },
              class: "inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors" %>
        </div>

        <div id="contacts-list" class="border rounded-lg divide-y bg-white shadow-sm">
          <% if contacts.any? %>
            <% contacts.each do |contact| %>
              <%= render Aeno::Examples::Contacts::ListItemComponent.new(contact: contact) %>
            <% end %>
          <% else %>
            <div class="p-8 text-center text-gray-500">
              No contacts yet. Create one to get started!
            </div>
          <% end %>
        </div>
      </div>
    ERB
  end
end

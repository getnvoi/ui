module Aeno::Examples::Contacts
  class DrawerContentComponent < ::Aeno::ApplicationViewComponent
    option :contact

    erb_template <<~ERB
      <%= render Aeno::Drawer::ContentComponent.new do |content| %>
        <%= content.with_header do %>
          <h2 class="text-lg font-semibold text-gray-900">
            <%= contact.persisted? ? "Edit Contact" : "New Contact" %>
          </h2>
        <% end %>

        <%= content.with_form(
          model: contact,
          url: contact.persisted? ? aeno_examples_contact_path(contact) : aeno_examples_contacts_path,
          method: contact.persisted? ? :patch : :post
        ) do |form| %>
          <%= form.with_item_input(
            type: :text,
            name: "name",
            label: "Name",
            required: true,
            placeholder: "John Doe"
          ) %>

          <%= form.with_item_input(
            type: :email,
            name: "email",
            label: "Email",
            required: true,
            placeholder: "john@example.com"
          ) %>

          <%= form.with_item_input(
            type: :text,
            name: "city",
            label: "City",
            placeholder: "San Francisco"
          ) %>

          <%= form.with_item_input(
            type: :text,
            name: "state",
            label: "State",
            placeholder: "CA"
          ) %>

          <%= form.with_submit(
            label: contact.persisted? ? "Update Contact" : "Create Contact",
            type: "submit"
          ) %>

          <%= form.with_action(
            label: "Cancel",
            variant: :secondary,
            type: "button",
            data: { action: "click->aeno--drawer#close" }
          ) %>
        <% end %>
      <% end %>
    ERB
  end
end

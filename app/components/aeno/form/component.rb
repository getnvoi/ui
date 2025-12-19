module Aeno::Form
  class Component < ::Aeno::ApplicationViewComponent
    option :model
    option :url
    option :method, default: proc { :post }
    option :data, default: proc { {} }
    option :css, optional: true

    def render_in(view_context, &block)
      @content_block = block
      super(view_context)
    end

    def render_form_layout(form_builder)
      layout = Aeno::Form::LayoutComponent.new(form_builder:)
      @content_block.call(layout) if @content_block
      render(layout)
    end

    private

      def form_options
        {
          class: "w-full #{css}",
          data: {
            role: "form",
            controller: "aeno--form",
            action: [data[:action], "submit->aeno--form#submit"].compact.join(" ")
          }.merge(data.except(:action))
        }
      end

      examples("Form", description: "Form component with integrated form_with") do |b|
        b.example(:basic, title: "Basic Form") do |e|
          e.preview(model: Aeno::Contact.new, url: "/contacts", method: :post, data: { "aeno--form-debug-value": true }) do |component|
            component.with_item_input(type: :text, name: "name", label: "Name")
            component.with_item_input(type: :text, name: "email", label: "Email")
            component.with_submit(label: "Submit", variant: :default, type: "submit")
          end
        end

        b.example(:with_groups, title: "Form with Groups") do |e|
          e.preview(model: Aeno::Contact.new, url: "/contacts", method: :post, data: { "aeno--form-debug-value": true }) do |component|
            component.with_item_group(title: "Contact Information") do |g|
              g.with_item_input(type: :text, name: "name", label: "Name")
              g.with_item_input(type: :text, name: "email", label: "Email")
            end
            component.with_item_group(title: "Address") do |g|
              g.with_item_row(css: "grid-cols-2") do |r|
                r.with_item_input(type: :text, name: "city", label: "City")
                r.with_item_input(type: :text, name: "address", label: "Address")
              end
            end
            component.with_submit(label: "Save", variant: :default, type: "submit")
            component.with_action(label: "Cancel", variant: :white, type: "button")
          end
        end

        b.example(:with_nested, title: "Simple Related Contacts") do |e|
          e.preview(model: Aeno::Contact.new, url: "/contacts", method: :post, data: { "aeno--form-debug-value": true }) do |component|
            component.with_item_input(type: :text, name: "name", label: "Name")
            component.with_item_input(type: :text, name: "email", label: "Email")

            component.with_item_nested(name: :related_contacts, label: "Related Contacts") do |n|
              n.with_item_input(type: :text, name: "name", label: "Contact Name")
              n.with_item_input(type: :text, name: "email", label: "Email")

              n.with_item_nested(name: :phones, label: "Phone Numbers") do |p|
                p.with_item_input(type: :text, name: "number", label: "Phone Number")
                p.with_item_input(type: :text, name: "phone_type", label: "Type")
              end
            end

            component.with_submit(label: "Create Contact", variant: :default, type: "submit")
          end
        end

        b.example(:with_relationship_type, title: "Related Contacts with Relationship Type") do |e|
          e.preview(model: Aeno::Contact.new, url: "/contacts", method: :post, data: { "aeno--form-debug-value": true }) do |component|
            component.with_item_input(type: :text, name: "name", label: "Name")
            component.with_item_input(type: :text, name: "email", label: "Email")

            component.with_item_nested(name: :contact_relationships, label: "Related Contacts") do |n|
              n.with_item_input(type: :text, name: "relation_type", label: "Relationship Type")
              n.with_item_nested(name: :related_contact, label: "Contact Details") do |rc|
                rc.with_item_input(type: :text, name: "name", label: "Contact Name")
                rc.with_item_input(type: :text, name: "email", label: "Email")
              end
            end

            component.with_submit(label: "Create Contact", variant: :default, type: "submit")
          end
        end

        b.example(:with_nested_in_group, title: "Deeply Nested Relationships") do |e|
          e.preview(model: Aeno::Contact.new, url: "/contacts", method: :post, data: { "aeno--form-debug-value": true }) do |component|
            component.with_item_input(type: :text, name: "name", label: "Name")
            component.with_item_input(type: :text, name: "email", label: "Email")

            component.with_item_group(title: "Relationships") do |g|
              g.with_item_nested(name: :contact_relationships, label: "Related Contacts") do |n|
                n.with_item_input(type: :text, name: "relation_type", label: "Relationship Type")

                n.with_item_nested(name: :related_contact, label: "Contact Details") do |rc|
                  rc.with_item_input(type: :text, name: "name", label: "Contact Name")
                  rc.with_item_input(type: :text, name: "email", label: "Email")

                  rc.with_item_nested(name: :phones, label: "Phone Numbers") do |p|
                    p.with_item_input(type: :text, name: "number", label: "Phone Number")
                    p.with_item_input(type: :text, name: "phone_type", label: "Type")
                  end
                end
              end
            end

            component.with_submit(label: "Save", variant: :default, type: "submit")
          end
        end

        b.example(:edit_existing, title: "Edit Contact with Existing Relations") do |e|
          contact = Aeno::Contact.new(id: 1, name: "John Doe", email: "john@example.com")

          # Build first related contact with phones
          related1 = contact.related_contacts.build(id: 10, name: "Jane Doe", email: "jane@example.com")
          related1.phones.build(id: 100, number: "555-1234", phone_type: "mobile")
          related1.phones.build(id: 101, number: "555-5678", phone_type: "work")

          # Build second related contact with one phone
          related2 = contact.related_contacts.build(id: 11, name: "Bob Smith", email: "bob@example.com")
          related2.phones.build(id: 102, number: "555-9999", phone_type: "home")

          e.preview(model: contact, url: "/contacts/1", method: :patch, data: { "aeno--form-debug-value": true }) do |component|
            component.with_item_input(type: :text, name: "name", label: "Name")
            component.with_item_input(type: :text, name: "email", label: "Email")

            component.with_item_nested(name: :related_contacts, label: "Related Contacts") do |n|
              n.with_item_input(type: :text, name: "name", label: "Contact Name")
              n.with_item_input(type: :text, name: "email", label: "Email")

              n.with_item_nested(name: :phones, label: "Phone Numbers") do |p|
                p.with_item_input(type: :text, name: "number", label: "Phone Number")
                p.with_item_input(type: :text, name: "phone_type", label: "Type")
              end
            end

            component.with_submit(label: "Update Contact", variant: :default, type: "submit")
          end
        end
      end
  end
end

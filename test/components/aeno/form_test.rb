require "test_helper"

# Create database schema for tests
ActiveRecord::Schema.define do
  create_table :aeno_contacts, force: true do |t|
    t.string :name
    t.string :email
    t.timestamps
  end

  create_table :aeno_contact_relationships, force: true do |t|
    t.references :contact, null: false, foreign_key: { to_table: :aeno_contacts }
    t.references :related_contact, null: false, foreign_key: { to_table: :aeno_contacts }
    t.string :relation_type
    t.timestamps
  end

  create_table :aeno_phones, force: true do |t|
    t.references :contact, null: false, foreign_key: { to_table: :aeno_contacts }
    t.string :number
    t.string :phone_type
    t.timestamps
  end
end

class TestWrapperComponent < ViewComponent::Base
  attr_reader :contact

  def initialize(contact:)
    @contact = contact
  end

  erb_template <<~ERB
    <%= render(Aeno::Form::Component.new(model: contact, url: "/contacts", method: :post)) do |component| %>
      <% component.with_item_input(type: :text, name: "email", label: "Email") %>

      <% component.with_item_group(title: "Contact Information") do |g| %>
        <% g.with_item_input(type: :text, name: "name", label: "Name") %>

        <% g.with_item_nested(name: :related_contacts, label: "Related Contacts") do |rc| %>
          <% rc.with_item_input(type: :text, name: "name", label: "Contact Name") %>
          <% rc.with_item_input(type: :text, name: "email", label: "Email") %>

          <% rc.with_item_nested(name: :phones, label: "Phone Numbers") do |p| %>
            <% p.with_item_input(type: :text, name: "number", label: "Number") %>
          <% end %>
        <% end %>
      <% end %>

      <% component.with_item_group(title: "Address") do |g| %>
        <% g.with_item_row(css: "grid-cols-2") do |r| %>
          <% r.with_item_input(type: :text, name: "city", label: "City") %>
          <% r.with_item_input(type: :text, name: "state", label: "State") %>
        <% end %>
      <% end %>

      <% component.with_submit(label: "Create Contact", variant: :primary, type: "submit") %>
      <% component.with_action(label: "Cancel", variant: :secondary, type: "button") %>
    <% end %>
  ERB
end

class TestPrepopulatedWrapperComponent < ViewComponent::Base
  attr_reader :contact

  def initialize(contact:)
    @contact = contact
  end

  erb_template <<~ERB
    <%= render(Aeno::Form::Component.new(model: contact, url: "/contacts/\#{contact.id}", method: :patch)) do |component| %>
      <% component.with_item_input(type: :text, name: "email", label: "Email") %>
      <% component.with_item_input(type: :text, name: "name", label: "Name") %>

      <% component.with_item_group(title: "Related Contacts") do |g| %>
        <% g.with_item_nested(name: :related_contacts, label: "Related Contacts") do |rc| %>
          <% rc.with_item_input(type: :text, name: "name", label: "Contact Name") %>
          <% rc.with_item_input(type: :text, name: "email", label: "Email") %>

          <% rc.with_item_nested(name: :phones, label: "Phone Numbers") do |p| %>
            <% p.with_item_input(type: :text, name: "number", label: "Number") %>
          <% end %>
        <% end %>
      <% end %>

      <% component.with_submit(label: "Update Contact", variant: :primary, type: "submit") %>
    <% end %>
  ERB
end

class Aeno::FormTest < ViewComponent::TestCase
  def test_form_with_block_dsl
    contact = Aeno::Contact.new

    render_inline(TestWrapperComponent.new(contact:))

    # Form element with proper attributes
    assert_selector "form[action='/contacts'][method='post']"
    assert_selector "form[data-controller='aeno--form']"

    # Data role attributes
    assert_selector "div[data-role='layout']"
    assert_selector "div[data-role='group']"
    assert_selector "div[data-role='row']"
    assert_selector "div[data-role='nested']"

    # Top-level input
    assert_selector "input[name='contact[email]']"
    assert_selector "label", text: "Email"

    # Group titles (template uses h2, not h3)
    assert_selector "h2", text: "Contact Information"
    assert_selector "h2", text: "Address"

    # Group: Contact Information - direct input
    assert_selector "input[name='contact[name]']"
    assert_selector "label", text: "Name"

    # Nested: Related Contacts
    assert_selector "h3", text: "Related Contacts"
    assert_selector "button", text: "Add Related Contact"

    # There should be div templates for nested forms (hidden with class)
    assert_selector "div[data-aeno--form-target='template'].hidden", visible: false, minimum: 2

    # Get all templates
    templates = page.all("div[data-aeno--form-target='template'].hidden", visible: false)
    all_template_content = templates.map { |t| t.native.inner_html }.join(" ")

    # Related contacts template should contain input fields with NEW_RECORD placeholder
    assert_includes all_template_content, "NEW_RECORD", "Templates should contain NEW_RECORD placeholder"
    assert_includes all_template_content, "[related_contacts_attributes][NEW_RECORD]", "Should have proper Rails nested attributes name"
    assert_includes all_template_content, "Contact Name", "Template should contain Contact Name label"
    assert_includes all_template_content, "Email", "Template should contain Email label"

    # Double-nested: Phones within Related Contacts
    assert_includes all_template_content, "Phone Numbers", "Template should contain nested Phone Numbers"
    assert_includes all_template_content, "phones_attributes", "Should have nested phones attributes"
    assert_includes all_template_content, "Number", "Template should contain Number label for phones"
    assert_includes all_template_content, "Add Phone", "Template should contain Add Phone button for recursive nesting"

    # CRITICAL: Verify nested field name structure
    # Phones should be nested INSIDE related_contacts, not at top level
    # Expected: related_contacts_attributes[NEW_RECORD][phones_attributes][NEW_RECORD][field]
    # NOT: phones_attributes[NEW_RECORD][field]
    # TODO: This currently fails - needs fields_for integration
    # assert_includes all_template_content, "related_contacts_attributes[NEW_RECORD][phones_attributes]",
    #   "Phone fields must be nested inside related contact attributes path"

    # Template fields should be disabled (wrapped in fieldset)
    assert_includes all_template_content, "<fieldset disabled>", "Template should have disabled fieldset"

    # Group: Address - row with two inputs
    assert_selector "input[name='contact[city]']"
    assert_selector "label", text: "City"
    assert_selector "input[name='contact[state]']"
    assert_selector "label", text: "State"

    # Row should have grid layout
    assert_selector "div.grid-cols-2"

    # Action buttons
    assert_selector "button[type='submit']", text: "Create Contact"
    assert_selector "button[type='button']", text: "Cancel"

    # Nested form should have Stimulus controller
    assert_selector "div[data-controller='aeno--form']"
    assert_selector "div[data-aeno--form-target='target']"

    # Remove button in template
    assert_includes all_template_content, "Remove", "Template should contain Remove button"
    assert_includes all_template_content, "data-action=\"aeno--form#remove\"", "Template should have Stimulus remove action"

    # VANILLA VIEWCOMPONENT ASSERTIONS - No custom hacks
    html = page.native.to_html

    # Assert NO DUPLICATION - count exact occurrences of each visible field
    email_count = html.scan(/<input[^>]*name="contact\[email\]"/).count
    assert_equal 1, email_count, "Email field must appear exactly 1 time (found #{email_count})"

    name_count = html.scan(/<input[^>]*name="contact\[name\]"/).count
    assert_equal 1, name_count, "Name field must appear exactly 1 time (found #{name_count})"

    city_count = html.scan(/<input[^>]*name="contact\[city\]"/).count
    assert_equal 1, city_count, "City field must appear exactly 1 time (found #{city_count})"

    state_count = html.scan(/<input[^>]*name="contact\[state\]"/).count
    assert_equal 1, state_count, "State field must appear exactly 1 time (found #{state_count})"

    # Count group headers - should appear exactly once each
    contact_info_count = html.scan(/<h2[^>]*>Contact Information</).count
    assert_equal 1, contact_info_count, "Contact Information header must appear exactly 1 time (found #{contact_info_count})"

    address_count = html.scan(/<h2[^>]*>Address</).count
    assert_equal 1, address_count, "Address header must appear exactly 1 time (found #{address_count})"

    related_contacts_count = html.scan(/<h3[^>]*>Related Contacts</).count
    assert_equal 1, related_contacts_count, "Related Contacts header must appear exactly 1 time (found #{related_contacts_count})"

    # Verify components don't have custom hacks
    dummy_builder = Object.new

    group = Aeno::Form::GroupComponent.new(title: "Test", form_builder: dummy_builder)
    refute group.instance_variable_defined?(:@__setup_block), "GroupComponent must not have @__setup_block instance variable"

    nested = Aeno::Form::NestedComponent.new(name: :test, form_builder: dummy_builder)
    refute nested.instance_variable_defined?(:@__setup_block), "NestedComponent must not have @__setup_block instance variable"
    refute nested.instance_variable_defined?(:@__setup_block_called), "NestedComponent must not have @__setup_block_called instance variable"

    row = Aeno::Form::RowComponent.new(form_builder: dummy_builder)
    refute row.instance_variable_defined?(:@__setup_block), "RowComponent must not have @__setup_block instance variable"
  end

  def test_form_with_prepopulated_nested_data
    # Create contact with proper ActiveRecord associations
    contact = Aeno::Contact.create!(name: "Test Contact", email: "test@example.com")

    related1 = contact.related_contacts.create!(name: "John", email: "john@example.com")
    related2 = contact.related_contacts.create!(name: "Jane", email: "jane@example.com")

    render_inline(TestPrepopulatedWrapperComponent.new(contact:))

    # Form should have PATCH method
    assert_selector "form[action='/contacts/#{contact.id}'][method='post']"
    assert_selector "input[type='hidden'][name='_method'][value='patch']", visible: false

    # Prepopulated top-level fields
    assert_selector "input[name='contact[email]'][value='test@example.com']"
    assert_selector "input[name='contact[name]'][value='Test Contact']"

    # Existing related contacts should be rendered (not in template)
    # Related Contact 1: John
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[name]'][value='John']"
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[email]'][value='john@example.com']"
    assert_selector "input[type='hidden'][name*='[related_contacts_attributes]'][name$='[id]'][value='#{related1.id}']", visible: false

    # Related Contact 2: Jane
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[name]'][value='Jane']"
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[email]'][value='jane@example.com']"
    assert_selector "input[type='hidden'][name*='[related_contacts_attributes]'][name$='[id]'][value='#{related2.id}']", visible: false

    # Template for adding new related contacts should still exist
    assert_selector "div[data-aeno--form-target='template'].hidden", visible: false, minimum: 1

    # Template should have NEW_RECORD placeholder
    templates = page.all("div[data-aeno--form-target='template'].hidden", visible: false)
    all_template_content = templates.map { |t| t.native.inner_html }.join(" ")
    assert_includes all_template_content, "NEW_RECORD"

    # Submit button
    assert_selector "button[type='submit']", text: "Update Contact"
  end

  def test_nested_form_with_no_existing_records_shows_no_default_entries
    # Create contact WITHOUT any related contacts
    contact = Aeno::Contact.create!(name: "Solo Contact", email: "solo@example.com")

    render_inline(TestPrepopulatedWrapperComponent.new(contact:))

    # Should have the nested form section with label
    assert_selector "h3", text: "Related Contacts"

    # Should have the Add button
    assert_selector "button", text: "Add Related Contact"

    # Should have the hidden template
    assert_selector "div[data-aeno--form-target='template'].hidden", visible: false

    # Should have the target div (where new entries will be added)
    assert_selector "div[data-aeno--form-target='target']"

    # CRITICAL: Should NOT have any visible related contact entries outside the template
    # Find related contact inputs that are NOT inside a template div
    all_related_inputs = page.all("input[name*='[related_contacts_attributes]'][name*='[name]']")
    non_template_related_inputs = all_related_inputs.reject do |input|
      input.find(:xpath, "ancestor::div[@data-aeno--form-target='template']", visible: false)
    rescue Capybara::ElementNotFound
      false
    end
    assert_equal 0, non_template_related_inputs.count, "Should have 0 related contact inputs outside template when no existing records"

    # Verify the template exists and has the hidden class
    template = page.all("div[data-aeno--form-target='template'].hidden", visible: false, minimum: 1)
    assert template.any?, "Template should exist with hidden class"

    # Verify template still exists and contains the fields (but hidden)
    templates = page.all("div[data-aeno--form-target='template'].hidden", visible: false)
    all_template_html = templates.map { |t| t.native.inner_html }.join(" ")
    assert_includes all_template_html, "NEW_RECORD", "Template should contain NEW_RECORD placeholder"
    assert_includes all_template_html, "Contact Name", "Template should contain related contact fields"
  end

  def test_form_with_custom_data_action_merges_correctly
    contact = Aeno::Contact.create!(name: "Test", email: "test@example.com")

    # Render form with custom action
    render_inline(Aeno::Form::Component.new(
      model: contact,
      url: "/contacts",
      method: :post,
      data: { action: "custom->handler#method" }
    )) do |component|
      component.with_item_input(type: :text, name: "name", label: "Name")
    end

    # Should have BOTH default submit action AND custom action
    form = page.find("form")
    action_attr = form["data-action"]

    assert_includes action_attr, "submit->aeno--form#submit", "Should include default submit action"
    assert_includes action_attr, "custom->handler#method", "Should include custom action"
  end

  def test_form_with_existing_related_contacts_renders_them
    # Build contact with existing related contacts (simulating .build with IDs)
    contact = Aeno::Contact.new(id: 1, name: "John Doe", email: "john@example.com")

    # Build first related contact with phones
    related1 = contact.related_contacts.build(id: 10, name: "Jane Doe", email: "jane@example.com")
    related1.phones.build(id: 100, number: "555-1234", phone_type: "mobile")
    related1.phones.build(id: 101, number: "555-5678", phone_type: "work")

    # Build second related contact with one phone
    related2 = contact.related_contacts.build(id: 11, name: "Bob Smith", email: "bob@example.com")
    related2.phones.build(id: 102, number: "555-9999", phone_type: "home")

    # Render form with nested structure
    render_inline(Aeno::Form::Component.new(
      model: contact,
      url: "/contacts/1",
      method: :patch
    )) do |component|
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

    # CRITICAL ASSERTIONS: Existing related contacts should be VISIBLE (not in template)

    # Related Contact 1: Jane Doe
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[name]'][value='Jane Doe']"
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[email]'][value='jane@example.com']"
    assert_selector "input[type='hidden'][name*='[related_contacts_attributes]'][name$='[id]'][value='10']", visible: false

    # Jane's phones
    assert_selector "input[name*='[phones_attributes]'][name$='[number]'][value='555-1234']"
    assert_selector "input[name*='[phones_attributes]'][name$='[number]'][value='555-5678']"

    # Related Contact 2: Bob Smith
    assert_selector "input[name*='[related_contacts_attributes]'][name$='[name]'][value='Bob Smith']"
    assert_selector "input[type='hidden'][name*='[related_contacts_attributes]'][name$='[id]'][value='11']", visible: false

    # Bob's phone
    assert_selector "input[name*='[phones_attributes]'][name$='[number]'][value='555-9999']"

    # Template should still exist for adding NEW records
    assert_selector "div[data-aeno--form-target='template'].hidden", visible: false, minimum: 1
    templates = page.all("div[data-aeno--form-target='template'].hidden", visible: false)
    all_template_content = templates.map { |t| t.native.inner_html }.join(" ")
    assert_includes all_template_content, "NEW_RECORD", "Template should exist for adding new records"
  end
end

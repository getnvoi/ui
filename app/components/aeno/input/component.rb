module Aeno::Input
  class Component < ::Aeno::ApplicationViewComponent
    option(:type, default: proc { :text })
    option(:label, optional: true)
    option(:name)
    option(:id, optional: true)
    option(:helper_text, optional: true)
    option(:error_text, optional: true)
    option(:disabled, default: proc { false })
    option(:required, default: proc { false })
    option(:data, default: proc { {} })

    # Additional options for specific input types
    option(:value, optional: true)
    option(:multiple, optional: true)
    option(:searchable, optional: true)
    option(:selected_value, optional: true)
    option(:selected_values, optional: true)

    def input_component
      "Aeno::Input::#{type.to_s.camelize}::Component".constantize
    end

    def call
      # Build options hash with only non-nil values
      extra_options = {}
      extra_options[:value] = value
      extra_options[:multiple] = multiple unless multiple.nil?
      extra_options[:searchable] = searchable unless searchable.nil?
      extra_options[:selected_value] = selected_value unless selected_value.nil?
      extra_options[:selected_values] = selected_values unless selected_values.nil?

      nested = input_component.new(name:, id:, disabled:, required:, data:, **extra_options)

      content_tag(:div, class: ["w-full", (disabled ? "opacity-50 pointer-events-none" : nil)].compact.join(" "), data: merged_data) do
        safe_join([
          (label_html if label),
          content_tag(:div, class: "relative") do
            render(nested, &@__vc_render_in_block)
          end,
          (error_html if error_text),
          (helper_html if !error_text && helper_text)
        ].compact)
      end
    end

    private

      def label_html
        content_tag(:label, for: id || name, class: "block text-sm font-medium text-gray-700 mb-1") do
          safe_join([
            label,
            (content_tag(:span, "*", class: "text-red-500") if required)
          ].compact)
        end
      end

      def error_html
        content_tag(:p, error_text, class: "mt-1 text-sm text-red-600")
      end

      def helper_html
        content_tag(:p, helper_text, class: "mt-1 text-sm text-gray-500")
      end

      examples("Input", description: "Form input components") do |b|
        b.example(:text, title: "Text Input") do |e|
          e.preview type: :text, name: "username"
          e.preview type: :text, name: "username", label: "Username", helper_text: "Enter your username"
          e.preview type: :text, name: "username", label: "Username", error_text: "Username is required"
          e.preview type: :text, name: "username", label: "Username", helper_text: "Enter your username", disabled: true
          e.preview type: :text, name: "username", label: "Username", helper_text: "Enter your username", value: "john_doe"
        end

        b.example(:password, title: "Password Input") do |e|
          e.preview type: :password, name: "password"
          e.preview type: :password, name: "password", label: "Password", helper_text: "Min 8 characters"
          e.preview type: :password, name: "password", label: "Password", error_text: "Password is required"
          e.preview type: :password, name: "password", label: "Password", helper_text: "Min 8 characters", disabled: true
          e.preview type: :password, name: "password", label: "Password", helper_text: "Min 8 characters", value: "secret123"
        end

        b.example(:text_area, title: "Text Area") do |e|
          e.preview type: :text_area, name: "message"
          e.preview type: :text_area, name: "message", label: "Message", helper_text: "Enter your message"
          e.preview type: :text_area, name: "message", label: "Message", error_text: "Message is required"
          e.preview type: :text_area, name: "message", label: "Message", helper_text: "Enter your message", disabled: true
          e.preview type: :text_area, name: "message", label: "Message", helper_text: "Enter your message", value: "This is a pre-filled message"
        end

        b.example(:select, title: "Select") do |e|
          e.preview type: :select, name: "option" do |select|
            select.with_option(value: "1", label: "Option 1")
            select.with_option(value: "2", label: "Option 2")
            select.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select, name: "option", label: "Select Option", helper_text: "Choose an option" do |select|
            select.with_option(value: "1", label: "Option 1")
            select.with_option(value: "2", label: "Option 2")
            select.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select, name: "option", label: "Select Option", error_text: "Selection is required" do |select|
            select.with_option(value: "1", label: "Option 1")
            select.with_option(value: "2", label: "Option 2")
            select.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select, name: "option", label: "Select Option", helper_text: "Choose an option", disabled: true do |select|
            select.with_option(value: "1", label: "Option 1")
            select.with_option(value: "2", label: "Option 2")
            select.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select, name: "option", label: "Select Option", helper_text: "Choose an option", value: "2" do |select|
            select.with_option(value: "1", label: "Option 1")
            select.with_option(value: "2", label: "Option 2")
            select.with_option(value: "3", label: "Option 3")
          end
        end

        b.example(:checkbox_collection, title: "Checkbox Collection") do |e|
          e.preview type: :checkbox_collection, name: "options" do |checkboxes|
            checkboxes.with_option(value: "1", label: "Option 1")
            checkboxes.with_option(value: "2", label: "Option 2")
            checkboxes.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :checkbox_collection, name: "options", label: "Select Options", helper_text: "Choose one or more" do |checkboxes|
            checkboxes.with_option(value: "1", label: "Option 1")
            checkboxes.with_option(value: "2", label: "Option 2")
            checkboxes.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :checkbox_collection, name: "options", label: "Select Options", error_text: "At least one option is required" do |checkboxes|
            checkboxes.with_option(value: "1", label: "Option 1")
            checkboxes.with_option(value: "2", label: "Option 2")
            checkboxes.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :checkbox_collection, name: "options", label: "Select Options", helper_text: "Choose one or more", disabled: true do |checkboxes|
            checkboxes.with_option(value: "1", label: "Option 1")
            checkboxes.with_option(value: "2", label: "Option 2")
            checkboxes.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :checkbox_collection, name: "options", label: "Select Options", helper_text: "Choose one or more", value: ["1", "3"] do |checkboxes|
            checkboxes.with_option(value: "1", label: "Option 1")
            checkboxes.with_option(value: "2", label: "Option 2")
            checkboxes.with_option(value: "3", label: "Option 3")
          end
        end

        b.example(:radio_collection, title: "Radio Collection") do |e|
          e.preview type: :radio_collection, name: "option" do |radios|
            radios.with_option(value: "1", label: "Option 1")
            radios.with_option(value: "2", label: "Option 2")
            radios.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :radio_collection, name: "option", label: "Select Option", helper_text: "Choose one" do |radios|
            radios.with_option(value: "1", label: "Option 1")
            radios.with_option(value: "2", label: "Option 2")
            radios.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :radio_collection, name: "option", label: "Select Option", error_text: "Selection is required" do |radios|
            radios.with_option(value: "1", label: "Option 1")
            radios.with_option(value: "2", label: "Option 2")
            radios.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :radio_collection, name: "option", label: "Select Option", helper_text: "Choose one", disabled: true do |radios|
            radios.with_option(value: "1", label: "Option 1")
            radios.with_option(value: "2", label: "Option 2")
            radios.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :radio_collection, name: "option", label: "Select Option", helper_text: "Choose one", value: "2" do |radios|
            radios.with_option(value: "1", label: "Option 1")
            radios.with_option(value: "2", label: "Option 2")
            radios.with_option(value: "3", label: "Option 3")
          end
        end

        b.example(:select_dropdown, title: "Select Dropdown (Single)") do |e|
          e.preview type: :select_dropdown, name: "option" do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select_dropdown, name: "option", label: "Select Option", helper_text: "Choose one" do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select_dropdown, name: "option", label: "Select Option", error_text: "Selection is required" do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select_dropdown, name: "option", label: "Select Option", helper_text: "Choose one", disabled: true do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
          end
          e.preview type: :select_dropdown, name: "option", label: "Select Option", helper_text: "Choose one", selected_value: "2" do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
          end
        end

        b.example(:select_dropdown_multiple, title: "Select Dropdown (Multiple)") do |e|
          e.preview type: :select_dropdown, name: "options", multiple: true do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
            dropdown.with_option(value: "4", label: "Option 4")
          end
          e.preview type: :select_dropdown, name: "options", label: "Select Options", helper_text: "Choose multiple", multiple: true do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
            dropdown.with_option(value: "4", label: "Option 4")
          end
          e.preview type: :select_dropdown, name: "options", label: "Select Options", error_text: "At least one required", multiple: true do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
            dropdown.with_option(value: "4", label: "Option 4")
          end
          e.preview type: :select_dropdown, name: "options", label: "Select Options", helper_text: "Choose multiple", disabled: true, multiple: true do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
            dropdown.with_option(value: "4", label: "Option 4")
          end
          e.preview type: :select_dropdown, name: "options", label: "Select Options", helper_text: "Choose multiple", selected_values: ["1", "3"], multiple: true do |dropdown|
            dropdown.with_option(value: "1", label: "Option 1")
            dropdown.with_option(value: "2", label: "Option 2")
            dropdown.with_option(value: "3", label: "Option 3")
            dropdown.with_option(value: "4", label: "Option 4")
          end
        end
      end
  end
end

module Aeno::Input::Select
  class Component < ::Aeno::FormBuilder::BaseComponent
    option(:prompt, optional: true)
    option(:collection, optional: true)
    option(:value_method, optional: true)
    option(:label_method, optional: true)

    option(:select_options, default: proc { [] })

    renders_many :options, "OptionComponent"

    def before_render
      select_options.each do |opt|
        with_option(**opt)
      end
    end

    class OptionComponent < ::Aeno::ApplicationViewComponent
      option(:value)
      option(:label)
      option(:selected, default: proc { false })
      option(:disabled, default: proc { false })

      erb_template <<~ERB
        <option value="<%= value %>" <%= 'selected' if selected %> <%= 'disabled' if disabled %>>
          <%= label %>
        </option>
      ERB
    end

    examples("Input Select", description: "Select dropdown input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "option"
      end
    end
  end
end

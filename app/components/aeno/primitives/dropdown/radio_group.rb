module Aeno::Primitives::Dropdown
  class RadioGroup < ::Aeno::ApplicationViewComponent
    option :name
    option :value, optional: true

    renders_many :items, ->(value:, **opts, &block) {
      RadioItem.new(name:, value:, checked: self.value == value, **opts, &block)
    }

    erb_template <<~ERB
      <div class="cp-dropdown__radio-group" role="group">
        <% items.each do |item| %><%= item %><% end %>
      </div>
    ERB
  end
end

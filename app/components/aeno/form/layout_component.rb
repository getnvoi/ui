module Aeno::Form
  class LayoutComponent < ::Aeno::ApplicationViewComponent
    include Aeno::Form::Concerns::InputSlots

    option :form_builder
    option :css, optional: true

    renders_many :items, types: {
      input: ->(**args) { input_slot_lambda.call(**args) },
      group: ->(**args) { GroupComponent.new(form_builder:, **args) },
      row: ->(**args) { RowComponent.new(form_builder:, **args) },
      nested: ->(**args, &block) { NestedComponent.new(form_builder:, **args, &block) }
    }

    renders_one :submit, Aeno::Button::Component
    renders_one :action, Aeno::Button::Component
  end
end

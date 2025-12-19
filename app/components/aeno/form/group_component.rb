module Aeno::Form
  class GroupComponent < ::Aeno::ApplicationViewComponent
    include Aeno::Form::Concerns::InputSlots

    option :title
    option :description, optional: true
    option :form_builder
    option :css, optional: true

    renders_many :items, types: {
      input: ->(**args) { input_slot_lambda.call(**args) },
      row: ->(**args) { RowComponent.new(form_builder:, **args) },
      nested: ->(**args, &block) { NestedComponent.new(form_builder:, **args, &block) }
    }
  end
end

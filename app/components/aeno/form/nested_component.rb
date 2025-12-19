module Aeno::Form
  class NestedComponent < ::Aeno::ApplicationViewComponent
    option :name
    option :label, optional: true
    option :form_builder
    option :css, optional: true
    option :wrapper_selector, default: proc { "[data-role='nested-item']" }
    option :add_button_label, optional: true
    option :add_button_icon, default: proc { "plus" }
    option :remove_button_label, default: proc { "Remove" }
    option :remove_button_icon, default: proc { "trash" }
    option :allow_destroy, default: proc { true }

    def initialize(name:, form_builder:, **options, &block)
      super(name:, form_builder:, **options)
      @content_block = block
    end

    def add_label
      add_button_label || "Add #{name.to_s.singularize.titleize}"
    end

    def render_nested_form(builder)
      form = Aeno::Form::LayoutComponent.new(form_builder: builder)
      @content_block.call(form) if @content_block
      render(form)
    end
  end
end

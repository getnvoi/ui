module Aeno::Table
  class ActionComponent < ::Aeno::ApplicationViewComponent
    option(:type)  # Required: :search, :button, :select, :confirm, :custom, :clear_filters
    option(:label, optional: true)
    option(:url, optional: true)
    option(:method, optional: true, default: proc { :get })
    option(:variant, optional: true)
    option(:icon, optional: true)
    option(:name, optional: true)
    option(:placeholder, optional: true)
    option(:debounce, optional: true, default: proc { 300 })
    option(:confirm_message, optional: true)
    option(:data, optional: true, default: proc { {} })
    option(:filter_names, optional: true, default: proc { [] })

    VALID_TYPES = [:search, :button, :select, :confirm, :custom, :clear_filters].freeze

    attr_accessor :select_block

    def initialize(**, &block)
      @select_block = block
      super(**)
      raise ArgumentError, "type is required" unless type
      raise ArgumentError, "type must be one of #{VALID_TYPES.join(', ')}" unless type.in?(VALID_TYPES)
    end

    def call
      case type
      when :search
        render_search
      when :button
        render_button
      when :select
        render_select
      when :confirm
        render_confirm
      when :clear_filters
        render_clear_filters
      when :custom
        content
      end
    end

    private

      def render_search
        data_attrs = {
          action: "input->aeno--table#search",
          "aeno--table-debounce-value": debounce
        }
        data_attrs["aeno--table-url-value"] = url if url

        render Aeno::Input::Text::Component.new(
          name:,
          placeholder:,
          value: current_value,
          data: action_data.merge(data_attrs)
        )
      end

      def render_button
        render Aeno::Button::Component.new(
          type: "button",
          label:,
          variant: variant || :secondary,
          icon:,
          data: action_data.merge(
            action: "click->aeno--table#performAction",
            "aeno--table-url-value": url,
            "aeno--table-method-value": method
          )
        )
      end

      def render_select
        data_attrs = {
          action: "change->aeno--table#performFilterAction"
        }
        data_attrs["aeno--table-url-value"] = url if url

        select_component = Aeno::Input::Select::Component.new(
          name:,
          id: name,
          value: current_value,
          data: action_data.merge(data_attrs)
        )

        @select_block.call(select_component) if @select_block

        render select_component
      end

      def render_confirm
        # Future implementation - modal confirmation before action
        content_tag(:div, "Confirm action (not yet implemented)")
      end

      def render_clear_filters
        return unless has_active_filters?

        render Aeno::Button::Component.new(
          type: "button",
          label: label || "Clear filters",
          variant: variant || :secondary,
          icon: icon || "x",
          data: action_data.merge(
            action: "click->aeno--table#clearFilters",
            "aeno--table-url-value": clear_url
          )
        )
      end

      def action_data
        data || {}
      end

      def current_value
        helpers.request.params[name]
      end

      def has_active_filters?
        return false if filter_names.empty?

        filter_names.any? { |filter_name| helpers.request.params[filter_name].present? }
      end

      def clear_url
        url || helpers.request.path
      end
  end
end

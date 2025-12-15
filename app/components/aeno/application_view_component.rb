module Aeno
  class ApplicationViewComponent < ViewComponentContrib::Base
    extend(Dry::Initializer)
    include(Turbo::StreamsHelper)
    include(Turbo::FramesHelper)
    include(Aeno::ApplicationHelper)
    include(LucideRails::RailsHelper)

    # ═══════════════════════════════════════════════════════════════════════════
    # PROPS DSL
    # ═══════════════════════════════════════════════════════════════════════════

    def self.prop_definitions
      @prop_definitions ||= {}
    end

    def self.prop(name, description:, values: nil, **opts)
      prop_definitions[name] = { description:, values: }.compact
      option(name, **opts)
    end

    def self.props
      ancestors
        .select { |a| a.respond_to?(:prop_definitions) }
        .reverse
        .reduce({}) { |h, a| h.merge(a.prop_definitions) }
    end

    # ═══════════════════════════════════════════════════════════════════════════
    # EXAMPLES DSL
    # ═══════════════════════════════════════════════════════════════════════════

    class ExamplePreview
      attr_reader :props

      def initialize(props)
        @props = props
      end
    end

    class Example
      attr_reader :key, :title, :description, :previews

      def initialize(key, title:, description: nil)
        @key = key
        @title = title
        @description = description
        @previews = []
      end

      def preview(**props)
        @previews << ExamplePreview.new(props)
      end
    end

    class ExamplesBuilder
      attr_reader :examples

      def initialize
        @examples = []
      end

      def example(key, title:, description: nil, &block)
        ex = Example.new(key, title:, description:)
        block.call(ex) if block
        @examples << ex
      end
    end

    def self.examples_config
      @examples_config ||= { title: nil, description: nil, examples: [] }
    end

    def self.examples(title, description: nil, &block)
      @examples_config = { title:, description:, examples: [] }
      builder = ExamplesBuilder.new
      block.call(builder) if block
      @examples_config[:examples] = builder.examples
    end

    def self.examples_title
      examples_config[:title]
    end

    def self.examples_description
      examples_config[:description]
    end

    def self.examples_list
      examples_config[:examples]
    end

    option(:css, optional: true)
    option(:style, optional: true)

    # Override in components: def default_style = { height: "300px" }
    def default_style = {}

    # Hash - for passing to child components
    def style_hash
      @style_hash ||= default_style.merge(style || {}).compact
    end

    # String - for HTML style attribute
    def merged_style
      @merged_style ||= style_hash
        .map { |k, v| "#{k.to_s.dasherize}: #{v}" }
        .join("; ")
        .presence
    end

    class << self
      def named
        @named ||= self.name.sub(/::Component$/, "").underscore.split("/").join("--").gsub("_", "-")
      end

      PREFIXES = {
        "Primitives" => "cp",
        "Blocks" => "cb",
        "Pages" => "cg"
      }.freeze

      # Component identifier for CSS scoping (e.g., "cp-card", "cb-sidebar")
      # Note: Can't use @identifier - ViewComponent uses it for file paths
      def css_identifier
        parts = self.name.to_s.sub(/::Component$/, "").split("::")
        prefix = PREFIXES[parts[-2]] || "c"
        component = parts.last.underscore.gsub("_", "-")
        "#{prefix}-#{component}"
      end
    end

    # Generate scoped CSS class name (e.g., "cp-card", "cp-card--centered")
    def class_for(name = nil)
      return self.class.css_identifier if name.nil? || name == "base"
      "#{self.class.css_identifier}--#{name}"
    end

    # Build classes from modifiers
    # Usage: classes(variant:, size:, disabled:, full:)
    # - symbol values: class_for(value) e.g. variant: :default → cp-button--default
    # - true: class_for(key) e.g. disabled: true → cp-button--disabled
    # - false/nil: skipped
    def classes(**mods)
      [
        class_for,
        *mods.filter_map { |k, v| v && class_for(v == true ? k.to_s : v.to_s) },
        css
      ].join(" ")
    end

    def controller_name
      # Match JS autoload naming for components/controllers:
      # - aeno/components/button/button_controller -> aeno--button
      name = self.class.name
        .sub(/^Aeno::/, "")
        .sub(/::Component$/, "")
        .underscore

      "aeno--#{name.gsub('/', '--').gsub('_', '-')}"
    end

    def data_target_key
      "#{controller_name}-target"
    end

    # Helper methods for Stimulus attributes
    # These return keys suited for Rails `data:` hashes (no `data-` prefix)
    def stimulus_controller
      { controller: controller_name }
    end

    def stimulus_target(name)
      { "#{controller_name}-target" => name }
    end

    def stimulus_action(event, method = nil)
      method ||= event
      { action: "#{event}->#{controller_name}##{method}" }
    end

    def stimulus_value(name, value)
      { "#{controller_name}-#{name}-value" => value }
    end

    def stimulus_class(name, css_class)
      { "#{controller_name}-#{name}-class" => css_class }
    end

    # Attribute helpers for raw tag helpers (already include `data-` prefix)
    def stimulus_attr_target(name)
      { "data-#{controller_name}-target" => name }
    end

    def merged_data
      return default_data unless respond_to?(:data) && data.keys

      data.merge(**default_data)
    end

    def default_data
      { controller: controller_name }
    end

    # Shared helper for rendering clickable elements
    # - button_to for non-GET methods (creates form)
    # - link_to for GET links
    # - button_tag for action buttons
    def action_tag(href: nil, method: nil, data: {}, form_data: {}, **opts, &block)
      if method && href
        helpers.button_to(href, method:, data:, form: { data: form_data }, **opts, &block)
      elsif href
        helpers.link_to(href, data:, **opts, &block)
      else
        helpers.button_tag(type: "button", data:, **opts, &block)
      end
    end
  end
end

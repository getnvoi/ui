module Aeno
  class ApplicationViewComponent < ViewComponentContrib::Base
    extend(Dry::Initializer)
    include(Turbo::StreamsHelper)
    include(Turbo::FramesHelper)
    include(Aeno::ApplicationHelper)
    include(LucideRails::RailsHelper)
    include(ViewComponentContrib::StyleVariants)
    include(Aeno::Concerns::ExamplesDsl)

    style_config.postprocess_with do |classes|
      TailwindMerge::Merger.new.merge(classes.join(" "))
    end

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
      attr_reader :props, :block, :template

      def initialize(props, block: nil, template: nil)
        @props = props
        @block = block
        @template = template
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

      def preview(**props, &block)
        @previews << ExamplePreview.new(props, block:)
      end

      def preview_template(template:, **props)
        @previews << ExamplePreview.new(props, template:)
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
    def default_styles
      TailwindMerge::Merger.new.merge([style, css].join(" "))
    end

    class << self
      def named
        @named ||= self.name.sub(/::Component$/, "").underscore.split("/").join("--").gsub("_", "-")
      end
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
      return default_data unless data.keys

      data.merge(**default_data)
    end

    def default_data
      { controller: controller_name }
    end
  end
end

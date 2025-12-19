# frozen_string_literal: true

module Aeno
  module Concerns
    module ExamplesDsl
      extend ActiveSupport::Concern

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

      class_methods do
        def examples_config
          @examples_config ||= { title: nil, description: nil, examples: [] }
        end

        def examples(title, description: nil, &block)
          @examples_config = { title:, description:, examples: [] }
          builder = ExamplesBuilder.new
          block.call(builder) if block
          @examples_config[:examples] = builder.examples
        end

        def examples_title
          examples_config[:title]
        end

        def examples_description
          examples_config[:description]
        end

        def examples_list
          examples_config[:examples]
        end
      end
    end
  end
end

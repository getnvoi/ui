# frozen_string_literal: true

require "test_helper"

class Aeros::ComponentsTest < ViewComponent::TestCase
  COMPONENTS_PATH = Aeros::Engine.root.join("app/components/aeros")

  # Dynamically discover all component classes
  def self.discover_components
    components = []

    %w[primitives blocks].each do |namespace|
      Dir.glob(COMPONENTS_PATH.join("#{namespace}/*/")).each do |path|
        name = File.basename(path)
        class_name = "Aeros::#{namespace.camelize}::#{name.camelize}::Component"
        begin
          klass = class_name.constantize
          components << { namespace: namespace, name: name, klass: klass }
        rescue NameError, NoMethodError
          # Skip components that can't be loaded
        end
      end
    end

    components
  end

  # Test: All components can be instantiated
  discover_components.each do |component|
    test "#{component[:namespace]}/#{component[:name]} can be instantiated" do
      klass = component[:klass]

      # Try to instantiate with no args first, fall back to examples
      instance = begin
        klass.new
      rescue KeyError, ArgumentError
        # Component has required props - try first example if available
        if klass.respond_to?(:examples_list) && klass.examples_list.any?
          first_example = klass.examples_list.first
          first_preview = first_example.previews.first
          klass.new(**first_preview.props) if first_preview
        end
      end

      assert_not_nil instance, "#{klass} should be instantiable"
    end
  end

  # Test: All primitives must have examples (documentation)
  # Blocks are internal and skipped for now
  discover_components.select { |c| c[:namespace] == "primitives" }.each do |component|
    test "#{component[:namespace]}/#{component[:name]} has examples defined" do
      klass = component[:klass]

      assert klass.respond_to?(:examples_list), "#{klass} must respond to examples_list"
      assert klass.examples_list.any?, "#{klass} must have at least one example"
      assert klass.examples_title.present?, "#{klass} must have examples title"
    end
  end

  # Test: All components must have styles.css
  discover_components.each do |component|
    test "#{component[:namespace]}/#{component[:name]} has styles.css" do
      styles_path = COMPONENTS_PATH.join(component[:namespace], component[:name], "styles.css")
      assert File.exist?(styles_path), "#{component[:namespace]}/#{component[:name]} must have styles.css"
    end
  end

  # Test: styles.css uses correct BEM prefix
  discover_components.each do |component|
    test "#{component[:namespace]}/#{component[:name]} styles.css uses correct BEM prefix" do
      styles_path = COMPONENTS_PATH.join(component[:namespace], component[:name], "styles.css")
      next unless File.exist?(styles_path)

      content = File.read(styles_path)
      prefix = component[:namespace] == "primitives" ? "cp" : "cb"
      component_name = component[:name].tr("_", "-")

      assert_match(/\.#{prefix}-#{component_name}/, content,
        "styles.css must use .#{prefix}-#{component_name} BEM prefix")
    end
  end

  # Test: All examples render without errors
  discover_components.each do |component|
    klass = component[:klass]

    next unless klass.respond_to?(:examples_list) && klass.examples_list.any?

    klass.examples_list.each do |example|
      example.previews.each_with_index do |preview, idx|
        test "#{component[:namespace]}/#{component[:name]} example '#{example.key}' preview #{idx} renders" do
          instance = klass.new(**preview.props)

          # Render should not raise
          render_inline(instance)

          assert_selector("*") # At least something rendered
        end
      end
    end
  end
end

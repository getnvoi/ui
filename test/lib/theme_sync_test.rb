# frozen_string_literal: true

require "test_helper"

class Aeros::ThemeSyncTest < ActiveSupport::TestCase
  COMPONENTS_PATH = Rails.root.join("../app/components/aeros/primitives")
  THEMES_PATH = Rails.root.join("../app/assets/stylesheets/aeros/themes")

  # Variables that are allowed but not in CORNERSTONES schema
  # These are generic/utility variables defined in themes or base.css
  ALLOWED_GENERIC_VARS = %w[
    --ui-background
    --ui-foreground
    --ui-border
    --ui-ring
    --ui-muted
    --ui-muted-foreground
    --ui-muted-color
    --ui-destructive
    --ui-primary
    --ui-accent
    --ui-accent-foreground
    --ui-popover
    --ui-shadow-lg
    --ui-shadow-xl
    --ui-radius
    --ui-radius-sm
    --ui-radius-md
    --ui-radius-lg
    --ui-spacing
    --ui-spacing-sm
    --ui-spacing-lg
    --ui-link
    --ui-link-hover
    --ui-ring-alpha
  ].freeze

  def schema_variables
    @schema_variables ||= begin
      vars = []
      Aeros::Theme::CORNERSTONES.each_value do |cornerstone|
        cornerstone[:properties].each_value do |prop|
          vars << prop[:var]
        end
      end
      vars
    end
  end

  def all_allowed_variables
    @all_allowed_variables ||= schema_variables + ALLOWED_GENERIC_VARS
  end

  def extract_css_variables_from_file(file_path)
    content = File.read(file_path)
    content.scan(/var\((--ui-[\w-]+)/).flatten.uniq
  end

  def extract_defined_variables_from_file(file_path)
    content = File.read(file_path)
    content.scan(/(--ui-[\w-]+):/).flatten.uniq
  end

  test "component CSS only uses allowed variables" do
    undefined_vars = {}

    Dir.glob(COMPONENTS_PATH.join("**/styles.css")).each do |file|
      used_vars = extract_css_variables_from_file(file)
      undefined = used_vars - all_allowed_variables

      if undefined.any?
        relative_path = Pathname.new(file).relative_path_from(COMPONENTS_PATH)
        undefined_vars[relative_path.to_s] = undefined
      end
    end

    assert undefined_vars.empty?,
      "Components use undefined CSS variables:\n" +
      undefined_vars.map { |file, vars| "  #{file}: #{vars.join(', ')}" }.join("\n")
  end

  test "theme presets define all required generic variables" do
    required_generic = ALLOWED_GENERIC_VARS.reject { |v| v.start_with?("--ui-radius", "--ui-spacing", "--ui-ring-alpha", "--ui-link") }
    all_missing = {}

    Dir.glob(THEMES_PATH.join("*.css")).each do |file|
      defined_vars = extract_defined_variables_from_file(file)
      missing = required_generic - defined_vars

      # Filter out vars that might be in base.css
      missing = missing.reject { |v| %w[--ui-radius --ui-spacing].any? { |prefix| v.start_with?(prefix) } }

      if missing.any?
        relative_path = Pathname.new(file).relative_path_from(THEMES_PATH)
        all_missing[relative_path.to_s] = missing
      end
    end

    assert all_missing.empty?,
      "Theme presets missing generic variables:\n" +
      all_missing.map { |file, vars| "  #{file}: #{vars.join(', ')}" }.join("\n")
  end

  test "theme presets define all cornerstone variables" do
    all_missing = {}

    Dir.glob(THEMES_PATH.join("*.css")).each do |file|
      defined_vars = extract_defined_variables_from_file(file)
      missing = schema_variables - defined_vars

      if missing.any?
        relative_path = Pathname.new(file).relative_path_from(THEMES_PATH)
        all_missing[relative_path.to_s] = missing
      end
    end

    assert all_missing.empty?,
      "Theme presets missing cornerstone variables:\n" +
      all_missing.map { |file, vars| "  #{file}: #{vars.join(', ')}" }.join("\n")
  end
end

# frozen_string_literal: true

require "test_helper"

class Aeno::ConfigurationTest < ActiveSupport::TestCase
  include Aeno::ApplicationHelper

  setup do
    Aeno.reset_configuration!
  end

  test "empty configuration produces no CSS" do
    assert_equal "", Aeno.configuration.theme_css
  end

  test "theme configuration produces CSS in aeno-config layer" do
    Aeno.configure do |config|
      config.theme do |t|
        t.input_bg = "#fafafa"
        t.input_border = "#d1d5db"
      end
    end

    css = Aeno.configuration.theme_css
    assert_includes css, "@layer aeno-config"
    assert_includes css, "--ui-input-bg:#fafafa"
    assert_includes css, "--ui-input-border:#d1d5db"
  end

  test "theme converts underscores to dashes in variable names" do
    Aeno.configure do |config|
      config.theme do |t|
        t.button_secondary_bg = "#ffffff"
      end
    end

    css = Aeno.configuration.theme_css
    assert_includes css, "--ui-button-secondary-bg:#ffffff"
  end

  test "aeno_theme_tag returns empty string when no config" do
    assert_equal "", aeno_theme_tag
  end

  test "aeno_theme_tag outputs style tag with config" do
    Aeno.configure do |config|
      config.theme do |t|
        t.input_bg = "#fafafa"
      end
    end

    output = aeno_theme_tag
    assert_includes output, "<style>"
    assert_includes output, "@layer aeno-config"
    assert_includes output, "--ui-input-bg:#fafafa"
    assert_includes output, "</style>"
  end
end

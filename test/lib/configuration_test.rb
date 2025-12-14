# frozen_string_literal: true

require "test_helper"

class Aeros::ConfigurationTest < ActiveSupport::TestCase
  include Aeros::ApplicationHelper

  setup do
    Aeros.reset_configuration!
  end

  test "empty configuration produces no CSS" do
    assert_equal "", Aeros.configuration.theme_css
  end

  test "theme configuration produces CSS in aeros-config layer" do
    Aeros.configure do |config|
      config.theme do |t|
        t.input_bg = "#fafafa"
        t.input_border = "#d1d5db"
      end
    end

    css = Aeros.configuration.theme_css
    assert_includes css, "@layer aeros-config"
    assert_includes css, "--ui-input-bg:#fafafa"
    assert_includes css, "--ui-input-border:#d1d5db"
  end

  test "theme converts underscores to dashes in variable names" do
    Aeros.configure do |config|
      config.theme do |t|
        t.button_secondary_bg = "#ffffff"
      end
    end

    css = Aeros.configuration.theme_css
    assert_includes css, "--ui-button-secondary-bg:#ffffff"
  end

  test "aeros_theme_tag returns empty string when no config" do
    assert_equal "", aeros_theme_tag
  end

  test "aeros_theme_tag outputs style tag with config" do
    Aeros.configure do |config|
      config.theme do |t|
        t.input_bg = "#fafafa"
      end
    end

    output = aeros_theme_tag
    assert_includes output, "<style>"
    assert_includes output, "@layer aeros-config"
    assert_includes output, "--ui-input-bg:#fafafa"
    assert_includes output, "</style>"
  end
end

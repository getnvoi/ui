# frozen_string_literal: true

module Aeros
  class Configuration
    attr_reader :theme_overrides

    def initialize
      @theme_overrides = {}
    end

    def theme
      yield ThemeBuilder.new(@theme_overrides) if block_given?
    end

    # Generate CSS for the aeros-config layer
    def theme_css
      return "" if @theme_overrides.empty?

      vars = @theme_overrides.map { |k, v| "#{k}:#{v}" }.join(";")
      "@layer aeros-config{:root{#{vars}}}"
    end

    class ThemeBuilder
      def initialize(overrides)
        @overrides = overrides
      end

      # Allow setting any --ui-* variable
      def method_missing(name, value = nil)
        if value
          # Remove trailing = from setter method name
          var_name = "--ui-#{name.to_s.chomp('=').tr('_', '-')}"
          @overrides[var_name] = value
        end
      end

      def respond_to_missing?(name, include_private = false)
        true
      end
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

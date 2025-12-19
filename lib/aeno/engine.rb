require "importmap-rails"
require "view_component-contrib"
require "dry-effects"
require "tailwind_merge"
require "lucide-rails"

module Aeno
  class << self
    attr_accessor :importmap
  end

  class Engine < ::Rails::Engine
    isolate_namespace Aeno

    # Support both Propshaft and Sprockets
    initializer "aeno.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("app/components")
      end
    end

    initializer "aeno.helpers" do
      ActiveSupport.on_load(:action_controller) do
        helper Aeno::ApplicationHelper
      end
    end

    initializer "aeno.importmap", before: "importmap" do |app|
      Aeno.importmap = Importmap::Map.new
      Aeno.importmap.draw(app.root.join("config/importmap.rb"))
      Aeno.importmap.draw(root.join("config/importmap.rb"))
      Aeno.importmap.cache_sweeper(watches: root.join("app/components"))

      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
      end

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Aeno.importmap.cache_sweeper.execute_if_updated }
      end
    end

    # # Ensure migrations are available to the host app
    # initializer "aeno.migrations" do
    #   unless Rails.env.test?
    #     config.paths["db/migrate"].expanded.each do |expanded_path|
    #       Rails.application.config.paths["db/migrate"] << expanded_path
    #     end
    #   end
    # end
  end
end

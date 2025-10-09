require "importmap-rails"
require "view_component-contrib"
require "dry-effects"
require "tailwind_merge"

module Aeros
  class << self
    attr_accessor :importmap
  end

  class Engine < ::Rails::Engine
    isolate_namespace Aeros

    # Support both Propshaft and Sprockets
    initializer "aeros.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("app/components")
      end
    end

    initializer "aeros.importmap", before: "importmap" do |app|
      Aeros.importmap = Importmap::Map.new
      Aeros.importmap.draw(app.root.join("config/importmap.rb"))
      Aeros.importmap.draw(root.join("config/importmap.rb"))
      Aeros.importmap.cache_sweeper(watches: root.join("app/components"))

      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
      end

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Aeros.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end

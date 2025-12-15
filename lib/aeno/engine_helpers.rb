module Aeno
  module EngineHelpers
    # Sets up importmap for a Rails engine with Aeno gem integration
    #
    # Usage in your engine.rb:
    #   module YourEngine
    #     class << self
    #       attr_accessor :importmap
    #     end
    #
    #     class Engine < ::Rails::Engine
    #       Aeno::EngineHelpers.setup_importmap(self, namespace: YourEngine)
    #     end
    #   end
    def self.setup_importmap(engine_class, namespace:)
      engine_class.initializer "#{namespace.name.underscore}.importmap", before: "importmap" do |app|
        namespace.importmap = Importmap::Map.new
        namespace.importmap.draw(app.root.join("config/importmap.rb"))
        namespace.importmap.draw(engine_class.root.join("config/importmap.rb"))
        namespace.importmap.draw(Aeno::Engine.root.join("config/importmap.rb"))
        namespace.importmap.cache_sweeper(watches: engine_class.root.join("app/javascript"))
        namespace.importmap.cache_sweeper(watches: engine_class.root.join("app/components"))

        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << engine_class.root.join("config/importmap.rb")
        end

        ActiveSupport.on_load(:action_controller_base) do
          before_action { namespace.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end

    # Sets up asset paths for a Rails engine
    def self.setup_assets(engine_class, namespace:)
      engine_class.initializer "#{namespace.name.underscore}.assets" do |app|
        if app.config.respond_to?(:assets)
          app.config.assets.paths << engine_class.root.join("app/javascript")
          app.config.assets.paths << engine_class.root.join("app/components")
        end
      end
    end
  end
end

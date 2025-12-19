module Aeno
  module ComponentDiscovery
    extend ActiveSupport::Concern

    class_methods do
      def discover_component_paths
        Dir.glob(Aeno::Engine.root.join("app/components/aeno/**/component.rb")).each_with_object({}) do |path, hash|
          full_path = path.match(/app\/components\/aeno\/(.+)\/component\.rb/)[1]

          # Skip nested components (e.g., conversation/message, layouts/agentic, dropdown/option)
          next if full_path.include?("/")

          name = full_path.split("/").last.underscore
          hash[name] = full_path
        end
      end
    end
  end
end

module Aeno
  class ShowcaseController < ApplicationController
    include ComponentDiscovery

    layout "aeno/application"
    before_action :load_components

    def index
    end

    def show
      component_path = component_paths[params[:id]]
      return render plain: "Component not found", status: :not_found unless component_path

      component_class = "Aeno::#{component_path.camelize}::Component".constantize
      @component = component_class
      @title = component_class.examples_title
      @description = component_class.examples_description
      @examples = component_class.examples_list
    end

    private

      def load_components
        @components = component_paths.keys.sort
      end

      def component_paths
        @component_paths ||= self.class.discover_component_paths
      end
  end
end

module Aeno
  class ShowcaseController < ApplicationController
    helper_method :primitives, :blocks

    def index
      page("showcase/index")
    end

    def show
      component_class = resolve_component(params[:namespace], params[:id])
      if component_class
        page("showcase/show", component_class:)
      else
        page("showcase/placeholder", namespace: params[:namespace], id: params[:id])
      end
    end

    private

      def resolve_component(namespace, id)
        ns = namespace.to_s.camelize
        name = id.to_s.camelize
        "Aeno::#{ns}::#{name}::Component".constantize
      rescue NameError, NoMethodError
        nil
      end

      def components_path
        Aeno::Engine.root.join("app/components/aeno")
      end

      def primitives
        @primitives ||= Dir.glob(components_path.join("primitives/*/")).map { |p| File.basename(p) }.sort
      end

      def blocks
        @blocks ||= Dir.glob(components_path.join("blocks/*/")).map { |p| File.basename(p) }.sort
      end
  end
end

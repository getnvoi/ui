module Aeno::Pages::Showcase::Index
  class Component < ::Aeno::ApplicationViewComponent
    def component_class(name)
      "Aeno::Primitives::#{name.to_s.camelize}::Component".constantize
    end
  end
end

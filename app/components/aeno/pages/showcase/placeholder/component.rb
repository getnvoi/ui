module Aeno::Pages::Showcase::Placeholder
  class Component < ::Aeno::ApplicationViewComponent
    option :namespace
    option :id

    def component_name
      id.to_s.titleize
    end
  end
end

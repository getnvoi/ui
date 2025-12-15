module Aeno::Primitives::Layouts::Agentic
  class Component < Aeno::ApplicationViewComponent
    renders_one :sidebar, Aeno::Primitives::Sidebar::Component

    def component_classes
      classes
    end
  end
end

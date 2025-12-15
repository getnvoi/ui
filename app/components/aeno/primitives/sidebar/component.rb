module Aeno::Primitives::Sidebar
  class Component < Aeno::ApplicationViewComponent
    renders_many(:items, Aeno::Primitives::Sidebar::Item)
    renders_many(:groups, Aeno::Primitives::Sidebar::Group)
    renders_one(:header, Aeno::Primitives::Sidebar::Header)
    renders_one(:footer, Aeno::Primitives::Sidebar::Footer)

    examples("Sidebar", description: "Navigation sidebar with groups and items") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end
    end
  end
end

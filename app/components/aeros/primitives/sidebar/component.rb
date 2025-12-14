module Aeros::Primitives::Sidebar
  class Component < Aeros::ApplicationViewComponent
    renders_many(:items, Aeros::Primitives::Sidebar::Item)
    renders_many(:groups, Aeros::Primitives::Sidebar::Group)
    renders_one(:header, Aeros::Primitives::Sidebar::Header)
    renders_one(:footer, Aeros::Primitives::Sidebar::Footer)

    examples("Sidebar", description: "Navigation sidebar with groups and items") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end
    end
  end
end

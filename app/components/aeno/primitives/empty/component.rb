module Aeno::Primitives::Empty
  class Component < ::Aeno::ApplicationViewComponent
    prop :icon, description: "Lucide icon name", optional: true

    renders_one(:title)

    examples("Empty", description: "Empty state placeholder") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end

      b.example(:with_icon, title: "With Icon") do |e|
        e.preview icon: "inbox"
        e.preview icon: "search"
      end
    end
  end
end

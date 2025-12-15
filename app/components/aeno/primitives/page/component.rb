module Aeno::Primitives::Page
  class Component < Aeno::ApplicationViewComponent
    prop :title, description: "Page title"
    prop :subtitle, description: "Optional subtitle", optional: true
    prop :description, description: "Page description", optional: true

    renders_one(:actions_area)

    examples("Page", description: "Page layout with title and content") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview title: "Dashboard"
      end

      b.example(:with_subtitle, title: "With Subtitle") do |e|
        e.preview title: "Users", subtitle: "(123)"
      end

      b.example(:with_description, title: "With Description") do |e|
        e.preview title: "Settings", description: "Manage your account settings"
      end
    end
  end
end

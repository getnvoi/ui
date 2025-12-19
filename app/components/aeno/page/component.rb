module Aeno::Page
  class Component < Aeno::ApplicationViewComponent
    option(:title)
    option(:subtitle, optional: true)
    option(:description, optional: true)

    renders_one(:actions_area)

    examples("Page", description: "Page layout") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview title: "Page Title", subtitle: "Subtitle", description: "This is a page description" do |page|
          page.with_actions_area do
            '<button class="px-4 py-2 bg-slate-600 text-white rounded">Action</button>'.html_safe
          end
          "Page content goes here"
        end
      end
    end
  end
end

module Aeno::Primitives::Layouts::App
  class Component < Aeno::ApplicationViewComponent
    renders_one :sidebar, ->(style: nil, &block) {
      Aeno::Primitives::Layouts::App::Sidebar.new(style:, &block)
    }
    renders_one :header
    renders_one :aside, ->(style: nil, &block) {
      Aeno::Primitives::Layouts::App::Aside.new(style:, &block)
    }
  end
end

module Aeno::Primitives::Sidebar
  class Header < Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <div><%= content %></div>
    ERB
  end
end

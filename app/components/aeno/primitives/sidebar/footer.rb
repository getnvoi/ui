module Aeno::Primitives::Sidebar
  class Footer < Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <div><%= content %></div>
    ERB
  end
end

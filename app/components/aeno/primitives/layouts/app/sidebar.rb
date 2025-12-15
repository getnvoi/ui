module Aeno::Primitives::Layouts::App
  class Sidebar < Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <aside class="cp-layout-app__sidebar" style="<%= merged_style %>">
        <%= content %>
      </aside>
    ERB
  end
end

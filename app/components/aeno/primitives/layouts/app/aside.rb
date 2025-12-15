module Aeno::Primitives::Layouts::App
  class Aside < Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <aside class="cp-layout-app__aside" style="<%= merged_style %>">
        <%= content %>
      </aside>
    ERB
  end
end

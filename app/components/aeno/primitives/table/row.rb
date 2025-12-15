module Aeno::Primitives::Table
  class Row < Aeno::ApplicationViewComponent
    renders_many :cells, Aeno::Primitives::Table::Cell

    erb_template <<~ERB
      <tr class="cp-table__tr <%= css %>">
        <% cells.each do |cell| %><%= cell %><% end %>
      </tr>
    ERB
  end
end

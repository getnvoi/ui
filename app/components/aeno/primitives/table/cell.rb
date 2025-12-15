module Aeno::Primitives::Table
  class Cell < Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <td class="cp-table__td <%= css %>"><%= content %></td>
    ERB
  end
end

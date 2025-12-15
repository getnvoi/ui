module Aeno::Primitives::Table
  class Column < Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <th scope="col" class="cp-table__th <%= css %>"><%= content %></th>
    ERB
  end
end

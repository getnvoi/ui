module Aeno::Primitives::Table
  class Header < Aeno::ApplicationViewComponent
    renders_many :columns, Aeno::Primitives::Table::Column

    erb_template <<~ERB
      <thead class="cp-table__head">
        <tr>
          <% columns.each do |column| %><%= column %><% end %>
        </tr>
      </thead>
    ERB
  end
end

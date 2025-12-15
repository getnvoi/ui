module Aeno::Primitives::Sidebar
  class Group < Aeno::ApplicationViewComponent
    option :label

    renders_many :items, Item

    erb_template <<~ERB
      <div class="cp-sidebar__group">
        <div class="cp-sidebar__group-label"><%= label %></div>
        <ul class="cp-sidebar__group-menu">
          <% items.each do |item| %>
            <li><%= item %></li>
          <% end %>
        </ul>
      </div>
    ERB
  end
end

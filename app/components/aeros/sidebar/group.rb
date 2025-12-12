module Aeros::Sidebar
  class Group < Aeros::ApplicationViewComponent
    option :label

    renders_many :items, Item

    style :container do
      base { "flex w-full min-w-0 flex-col px-0 py-1" }
    end

    style :label do
      base { "text-zinc-500 h-8 flex items-center px-2 text-xs font-medium uppercase tracking-wide" }
    end

    style :menu do
      base { "flex w-full min-w-0 flex-col gap-1" }
    end

    erb_template <<~ERB
      <div class="<%= style(:container) %>">
        <div class="<%= style(:label) %>"><%= label %></div>
        <ul class="<%= style(:menu) %>">
          <% items.each do |item| %>
            <li><%= item %></li>
          <% end %>
        </ul>
      </div>
    ERB
  end
end

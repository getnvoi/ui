module Aeros::Sidebar
  class Item < Aeros::ApplicationViewComponent
    option :label
    option :href
    option :icon, optional: true
    option :active, default: proc { false }

    style do
      base do
        %w[
          flex w-full items-center gap-2 rounded-md p-2 text-left text-sm
          text-zinc-700
          hover:bg-zinc-100 hover:text-zinc-900
          transition-colors
          [&>svg]:w-4 [&>svg]:h-4 [&>svg]:flex-shrink-0
        ]
      end

      variants do
        active do
          yes { "bg-zinc-100 font-medium text-zinc-900" }
        end
      end
    end

    def classes
      style(active:)
    end

    erb_template <<~ERB
      <%= link_to(href, class: classes, data: { active: active }) do %>
        <%= lucide_icon(icon) if icon %>
        <span><%= label %></span>
      <% end %>
    ERB
  end
end

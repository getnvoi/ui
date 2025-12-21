module Aeno::Button
  class Component < ::Aeno::ApplicationViewComponent
    option(:css, optional: true)
    option(:type, optional: true)
    option(:label, optional: true)
    option(:method, optional: true)
    option(:href, optional: true)
    option(:data, default: proc { {} })
    option(:icon, optional: true)
    option(:variant, default: proc { :default })
    option(:disabled, default: proc { false })
    option(:full, default: proc { false })
    option(:size, default: proc { nil })
    option(:as, default: proc { :button })
    option(:target, optional: true)

    style do
      base do
        %w[
          inline-flex
          items-center
          justify-center
          gap-gap
          text-ui
          font-weight-ui
          cursor-pointer
          [&>svg]:flex-shrink-0
          [&>svg]:w-icon-sm
          [&>svg]:h-icon-sm
        ]
      end

      variants do
        variant do
          primary { "bg-primary-solid hover:bg-primary-hover text-white" }
          outline { "bg-white hover:bg-secondary-hover text-foreground border border-border" }
          destructive { "bg-destructive-solid hover:bg-destructive-hover text-white" }
        end

        disabled do
          yes { "opacity-disabled pointer-events-none" }
        end

        full do
          yes { "w-full" }
        end

        size do
          xs { "h-control-sm px-button-x-sm rounded-button-sm" }
          xl { "h-control-lg px-button-x-lg rounded-button-lg [&>svg]:w-icon-md [&>svg]:h-icon-md" }
        end
      end

      defaults do
        { variant: :primary, size: nil }
      end
    end

    def classes
      size_classes = size ? nil : "h-control px-button-x rounded-button"
      [
        css,
        size_classes,
        style(variant:, disabled:, full:, size:)
      ].compact.join(" ")
    end

    examples("Button", description: "Clickable actions and navigation links") do |b|
      b.example(:variants, title: "Variants") do |e|
        e.preview variant: :primary, label: "Primary"
        e.preview variant: :outline, label: "Outline"
        e.preview variant: :destructive, label: "Destructive"
      end

      b.example(:sizes, title: "Sizes") do |e|
        e.preview size: :xs, label: "Extra Small"
        e.preview label: "Default"
        e.preview size: :xl, label: "Extra Large"
      end

      b.example(:icons, title: "With Icons") do |e|
        e.preview icon: "settings", label: "Settings", variant: :primary
        e.preview icon: "trash", label: "Delete", variant: :destructive
      end

      b.example(:states, title: "States") do |e|
        e.preview label: "Disabled", disabled: true
        e.preview label: "Full Width", full: true
      end
    end

    erb_template <<~ERB
      <% if href %>
        <%= link_to(href, method:, data: merged_data, class: classes, target:) do %>
          <%= lucide_icon(icon, class: "flex-shrink-0 icon") if icon %>
          <%= ui("spinner", size: :sm, variant: :white, css: "spinner hidden") %>
          <% if label %><span class="truncate flex-shrink" data-role="label"><%= label %></span><% end %>
        <% end %>
      <% else %>
        <%= content_tag(as, data: merged_data, type: type || "button", class: classes) do %>
          <%= lucide_icon(icon, class: "flex-shrink-0 icon") if icon %>
          <%= ui("spinner", size: :sm,  variant: :white, css: "spinner hidden") %>
          <% if label %><span class="truncate flex-shrink" data-role="label"><%= label %></span><% end %>
        <% end %>
      <% end %>
    ERB
  end
end

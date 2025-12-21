# frozen_string_literal: true

module Aeno
  module Divider
    class Component < Aeno::ApplicationViewComponent
      option :label, optional: true
      option :orientation, default: -> { :horizontal }

      style :container do
        base { "relative my-6" }

        variants do
          orientation do
            horizontal { "flex items-center" }
            vertical { "flex flex-col items-center h-24" }
          end
        end
      end

      style :line do
        base { "border-border" }

        variants do
          orientation do
            horizontal { "w-full border-t" }
            vertical { "h-full border-l" }
          end
        end
      end

      style :label_text do
        base { "bg-background text-muted-foreground text-ui" }

        variants do
          orientation do
            horizontal { "px-pad-sm" }
            vertical { "py-pad-sm" }
          end
        end
      end

      examples("Divider", description: "Visual separator for content sections") do |b|
        b.example(:default, title: "Default Horizontal") do |e|
          e.preview
        end

        b.example(:with_label, title: "With Label") do |e|
          e.preview label: "Or continue with"
          e.preview label: "Section Title"
        end

        b.example(:vertical, title: "Vertical") do |e|
          e.preview orientation: :vertical
        end

        b.example(:vertical_with_label, title: "Vertical With Label") do |e|
          e.preview orientation: :vertical, label: "OR"
        end
      end
    end
  end
end

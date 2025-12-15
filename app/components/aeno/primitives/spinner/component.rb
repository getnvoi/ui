module Aeno::Primitives::Spinner
  class Component < ::Aeno::ApplicationViewComponent
    prop :size, description: "Spinner size", values: [:sm, :default, :lg], default: -> { :default }
    prop :variant, description: "Spinner color variant", values: [:default, :white], default: -> { :default }

    examples("Spinner", description: "Loading indicator") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end

      b.example(:sizes, title: "Sizes") do |e|
        e.preview size: :sm
        e.preview size: :default
        e.preview size: :lg
      end

      b.example(:variants, title: "Variants") do |e|
        e.preview variant: :default
        e.preview variant: :white
      end
    end

    def classes
      [
        class_for("base"),
        class_for(size.to_s),
        class_for(variant.to_s),
        css
      ].compact.join(" ")
    end

    erb_template <<~ERB
      <span class="<%= classes %>"></span>
    ERB
  end
end

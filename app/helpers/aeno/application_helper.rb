module Aeno
  module ApplicationHelper
    def page(name, *args, **kwargs, &block)
      component = "Aeno::Pages::#{name.split("/").map(&:camelize).join("::")}::Component".constantize
      render(component.new(*args, **kwargs), &block)
    end

    def ui(name, *args, **kwargs, &block)
      class_name = name.to_s.tr("-", "_").camelize
      component = "Aeno::Primitives::#{class_name}::Component".constantize
      render(component.new(*args, **kwargs), &block)
    end

    def block(name, *args, **kwargs, &blk)
      class_name = name.to_s.tr("-", "_").camelize
      component = "Aeno::Blocks::#{class_name}::Component".constantize
      render(component.new(*args, **kwargs), &blk)
    end

    # Output theme configuration as inline CSS in the aeno-config layer
    def aeno_theme_tag
      css = Aeno.configuration.theme_css
      return "".html_safe if css.empty?

      "<style>#{css}</style>".html_safe
    end
  end
end

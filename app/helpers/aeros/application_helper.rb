module Aeros
  module ApplicationHelper
    def page(name, *args, **kwargs, &block)
      component = "Aeros::Pages::#{name.split("/").map(&:camelize).join("::")}::Component".constantize
      render(component.new(*args, **kwargs), &block)
    end

    def ui(name, *args, **kwargs, &block)
      class_name = name.to_s.tr("-", "_").camelize
      component = "Aeros::Primitives::#{class_name}::Component".constantize
      render(component.new(*args, **kwargs), &block)
    end

    def block(name, *args, **kwargs, &blk)
      class_name = name.to_s.tr("-", "_").camelize
      component = "Aeros::Blocks::#{class_name}::Component".constantize
      render(component.new(*args, **kwargs), &blk)
    end

    # Output theme configuration as inline CSS in the aeros-config layer
    def aeros_theme_tag
      css = Aeros.configuration.theme_css
      return "".html_safe if css.empty?

      "<style>#{css}</style>".html_safe
    end
  end
end

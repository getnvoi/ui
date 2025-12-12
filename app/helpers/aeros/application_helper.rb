module Aeros
  module ApplicationHelper
    def ui(name, *args, **kwargs, &block)
      component = "Aeros::#{name.to_s.tr('-', '_').camelize}::Component".constantize
      render(component.new(*args, **kwargs), &block)
    end
  end
end

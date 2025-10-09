module Aeros
  module ApplicationHelper
    def sqema_importmap_tags(entry_point = "application", shim: true)
      safe_join [
        javascript_inline_importmap_tag(Aeros.importmap.to_json(resolver: self)),
        javascript_importmap_module_preload_tags(Aeros.importmap),
        javascript_import_module_tag(entry_point)
      ].compact, "\n"
    end

    def ui(name, *args, **kwargs, &block)
      component = "Aeros::#{name.to_s.camelize}::Component".constantize
      render(component.new(*args, **kwargs), &block)
    end
  end
end

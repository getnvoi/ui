module Aeros::Sidebar
  class Component < Aeros::ApplicationViewComponent
    class Header < Aeros::ApplicationViewComponent
      erb_template <<~ERB
        <div class="<%= default_styles %>"><%= content %></div>
      ERB
    end

    class Footer < Aeros::ApplicationViewComponent
      erb_template <<~ERB
        <div class="<%= default_styles %>"><%= content %></div>
      ERB
    end

    renders_many(:items, Aeros::Sidebar::Item)
    renders_many(:groups, Aeros::Sidebar::Group)
    renders_one(:header, Header)
    renders_one(:footer, Footer)

    style do
      base do
        [
          "h-screen",
          "flex",
          "flex-col",
          "overflow-hidden",
          "[&>.main]:h-full",
          "[&>.main]:w-full",
          "[&>.main]:min-w-0",
          "[&>.main]:min-h-0",
          "[&>.main]:flex-1",
          "[&>.main]:flex-col",
          "[&>.main]:flex",
          "[&>.main]:overflow-hidden",
          "[&>.main_.header]:flex-shrink-0",
          "[&>.main_.content]:flex-1",
          "[&>.main_.content]:min-w-0",
          "[&>.main_.content]:overflow-hidden",
          "[&>.main_.content>*]:min-w-0",
          "[&>.main_.content>*]:max-w-full",
          "[&>.main_.nav]:flex-1",
          "[&>.main_.nav]:overflow-y-auto",
          "[&>.main_.nav]:px-2",
          "[&>.footer]:flex-shrink-0"
        ]
      end
    end

    style :menu do
      base { "flex w-full min-w-0 flex-col gap-1" }
    end
  end
end

module Aeros::Layouts::Agentic
  class Component < Aeros::ApplicationViewComponent
    renders_one(:sidebar, Aeros::Sidebar::Component.name)

    style do
      base do
        [
          "fixed",
          "top-0",
          "left-0",
          "right-0",
          "bottom-0",
          "w-screen",
          "h-screen",
          "grid",
          "grid-cols-[1fr_5fr]",
          "divide-x",
          "divide-slate-200"
        ]
      end
    end
  end
end

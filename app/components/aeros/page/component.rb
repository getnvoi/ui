module Aeros::Page
  class Component < Aeros::ApplicationViewComponent
    option(:title)
    option(:subtitle, optional: true)
    option(:description, optional: true)

    renders_one(:actions_area)
  end
end

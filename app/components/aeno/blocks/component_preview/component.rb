# frozen_string_literal: true

module Aeno::Blocks::ComponentPreview
  class Component < ::Aeno::ApplicationViewComponent
    option(:title, optional: true)
    option(:description, optional: true)

    def default_style = { height: "300px" }
  end
end

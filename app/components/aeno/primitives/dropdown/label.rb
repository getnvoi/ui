module Aeno::Primitives::Dropdown
  class Label < ::Aeno::ApplicationViewComponent
    erb_template <<~ERB
      <div class="cp-dropdown__label"><%= content %></div>
    ERB
  end
end

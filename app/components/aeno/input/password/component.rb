module Aeno::Input::Password
  class Component < ::Aeno::FormBuilder::BaseComponent
    option(:autocomplete, default: proc { "current-password" })
    option(:show_toggle, default: proc { true })

    examples("Input Password", description: "Password input field") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "password"
      end
    end
  end
end

module Aeros::InputPassword
  class Component < ::Aeros::FormBuilder::BaseComponent
    option(:autocomplete, default: proc { "current-password" })
    option(:show_toggle, default: proc { true })
  end
end

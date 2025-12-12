module Aeros::InputTextArea
  class Component < ::Aeros::FormBuilder::BaseComponent
    option(:rows, default: proc { 4 })
  end
end

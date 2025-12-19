module Aeno::Input::TextArea
  class Component < ::Aeno::FormBuilder::BaseComponent
    option(:rows, default: proc { 4 })

    examples("Input Text Area", description: "Multi-line text input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "message"
      end
    end
  end
end

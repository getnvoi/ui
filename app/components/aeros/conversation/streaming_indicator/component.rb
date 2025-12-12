module Aeros::Conversation::StreamingIndicator
  class Component < ::Aeros::ApplicationViewComponent
    option(:role, default: proc { "assistant" })
    option(:label, default: proc { "Assistant" })
    option(:css, optional: true)

    style do
      base { "py-8 bg-gray-50" }
    end

    def avatar_color
      case role
      when "user"
        "bg-blue-600"
      when "assistant"
        "bg-green-600"
      else
        "bg-gray-600"
      end
    end

    def avatar_label
      case role
      when "user"
        "U"
      when "assistant"
        "A"
      else
        role[0].upcase
      end
    end
  end
end

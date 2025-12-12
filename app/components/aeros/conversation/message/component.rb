module Aeros::Conversation::Message
  class Component < ::Aeros::ApplicationViewComponent
    option(:role, default: proc { "assistant" })
    option(:content, default: proc { "" })
    option(:timestamp, optional: true)
    option(:css, optional: true)

    style do
      base { "py-8" }

      variants do
        role do
          user { "bg-white" }
          assistant { "bg-gray-50" }
          error { "bg-white" }
          # system { "bg-blue-50" } # TODO: Fix - conflicts with Kernel#system
        end
      end
    end

    def avatar_color
      case role
      when "user"
        "bg-blue-600"
      when "assistant"
        "bg-green-600"
      when "error"
        "bg-red-600"
      when "system"
        "bg-gray-600"
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
      when "error"
        "!"
      when "system"
        "S"
      else
        "?"
      end
    end

    def role_label
      case role
      when "user"
        "You"
      when "assistant"
        "Assistant"
      when "error"
        "Error"
      when "system"
        "System"
      else
        role.capitalize
      end
    end
  end
end

module Aeno::Primitives::Conversation::Message
  class Component < ::Aeno::ApplicationViewComponent
    prop :role, description: "Message role", values: [:user, :assistant, :error, :system], default: -> { "assistant" }
    prop :content, description: "Message content", default: -> { "" }
    prop :timestamp, description: "Message timestamp", optional: true

    def role_class
      "cp-conversation-message--#{role}"
    end

    def avatar_class
      "cp-conversation-message__avatar--#{role}"
    end

    def role_label
      case role.to_s
      when "user" then "You"
      when "assistant" then "Assistant"
      when "error" then "Error"
      when "system" then "System"
      else role.to_s.capitalize
      end
    end

    def avatar_label
      case role.to_s
      when "user" then "U"
      when "assistant" then "A"
      when "error" then "!"
      when "system" then "S"
      else "?"
      end
    end
  end
end

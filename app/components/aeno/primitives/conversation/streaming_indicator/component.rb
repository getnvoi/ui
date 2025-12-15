module Aeno::Primitives::Conversation::StreamingIndicator
  class Component < ::Aeno::ApplicationViewComponent
    prop :role, description: "Role being streamed", default: -> { "assistant" }
    prop :label, description: "Label text", default: -> { "Assistant" }

    def avatar_class
      "cp-conversation-streaming__avatar--#{role}"
    end

    def avatar_label
      case role.to_s
      when "user" then "U"
      when "assistant" then "A"
      else role.to_s[0].upcase
      end
    end
  end
end

module Aeros::Primitives::Conversation
  class Component < ::Aeros::ApplicationViewComponent
    prop :title, description: "Chat title", optional: true
    prop :streaming, description: "Show streaming indicator", default: -> { false }

    renders_many(:messages, Message::Component.name)
    renders_one(:user_message_box, UserMessageBox::Component.name)

    examples("Conversation", description: "Chat conversation interface") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview title: "Chat"
      end
    end
  end
end

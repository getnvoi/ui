module Aeno::Primitives::Conversation
  class Component < ::Aeno::ApplicationViewComponent
    prop :title, description: "Chat title", optional: true
    prop :streaming, description: "Show streaming indicator", default: -> { false }

    renders_many :messages, Message::Component
    renders_one :user_message_box, UserMessageBox::Component

    examples("Conversation", description: "Chat conversation interface") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview title: "Chat"
      end
    end
  end
end

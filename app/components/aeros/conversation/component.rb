module Aeros::Conversation
  class Component < ::Aeros::ApplicationViewComponent
    option(:title, optional: true)
    option(:streaming, default: proc { false })

    renders_many(:messages, Message::Component.name)
    renders_one(:user_message_box, UserMessageBox::Component.name)

    style do
      base { "flex h-full flex-col bg-white" }
    end
  end
end

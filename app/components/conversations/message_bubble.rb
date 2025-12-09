# frozen_string_literal: true

module Components
  module Conversations
    class MessageBubble < Components::Base
    def initialize(message:, current_user:)
      @message = message
      @current_user = current_user
      @is_sent = message.sender_id == current_user.id
    end

    def view_template
      div(class: [
        "flex mb-4",
        @is_sent ? "justify-end" : "justify-start"
      ]) do
        div(class: [
          "max-w-[75%] rounded-2xl px-4 py-2",
          @is_sent ? "bg-primary text-primary-foreground rounded-br-md" : "bg-muted rounded-bl-md"
        ]) do
          p(class: "text-sm whitespace-pre-wrap break-words") { @message.content }
          p(class: [
            "text-xs mt-1",
            @is_sent ? "text-primary-foreground/70" : "text-muted-foreground"
          ]) do
            @message.created_at.strftime("%I:%M %p")
          end
        end
      end
    end
    end
  end
end

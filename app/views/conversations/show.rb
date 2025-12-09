# frozen_string_literal: true

module Views
  module Conversations
    class Show < Views::Base
      def initialize(conversation:, messages:, other_participant:, current_user:)
        @conversation = conversation
        @messages = messages
        @other_participant = other_participant
        @current_user = current_user
      end

      def view_template
        div(class: "flex flex-col h-[calc(100vh-10rem)] sm:h-[calc(100vh-8rem)]") do
          # Header
          render_header

          # Messages
          div(
            class: "flex-1 overflow-y-auto p-4",
            id: "messages-container"
          ) do
            turbo_frame_tag "messages" do
              if @messages.any?
                @messages.each do |message|
                  render Components::Conversations::MessageBubble.new(
                    message: message,
                    current_user: @current_user
                  )
                end
              else
                div(class: "text-center text-muted-foreground py-8") do
                  p { "No messages yet. Start the conversation!" }
                end
              end
            end
          end

          # Message Input
          render_message_input
        end
      end

      private

      def render_header
        div(class: "flex items-center gap-3 p-4 border-b border-border bg-background") do
          a(href: conversations_path, class: "sm:hidden") do
            render Components::Icons::ChevronLeft.new(size: :md)
          end

          Avatar do
            if @other_participant.avatar_url.present?
              AvatarImage(src: @other_participant.avatar_url, alt: @other_participant.display_name)
            end
            AvatarFallback { participant_initials }
          end

          div(class: "flex-1") do
            p(class: "font-semibold") { @other_participant.display_name }
            if @other_participant.provider?
              p(class: "text-sm text-muted-foreground") do
                @other_participant.provider_profile&.business_name
              end
            end
          end
        end
      end

      def render_message_input
        div(class: "border-t border-border p-4 bg-background") do
          form(
            action: conversation_messages_path(@conversation),
            method: "post",
            class: "flex gap-2",
            data: { turbo_frame: "messages" }
          ) do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            Input(
              type: "text",
              name: "message[content]",
              placeholder: "Type a message...",
              required: true,
              class: "flex-1",
              autocomplete: "off"
            )

            Button(type: "submit", variant: :primary, icon: true) do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke_width: "2",
                stroke: "currentColor",
                class: "w-5 h-5"
              ) do |s|
                s.path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  d: "M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5"
                )
              end
            end
          end
        end
      end

      def participant_initials
        first = @other_participant.first_name&.first&.upcase || ""
        last = @other_participant.last_name&.first&.upcase || ""
        initials = "#{first}#{last}"
        initials.present? ? initials : @other_participant.email_address&.first&.upcase || "U"
      end
    end
  end
end

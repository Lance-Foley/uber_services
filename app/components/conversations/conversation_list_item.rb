# frozen_string_literal: true

module Components
  module Conversations
    class ConversationListItem < Components::Base
    def initialize(conversation:, current_user:)
      @conversation = conversation
      @current_user = current_user
      @other_user = other_participant
      @last_message = conversation.messages.order(created_at: :desc).first
    end

    def view_template
      a(
        href: conversation_path(@conversation),
        class: [
          "flex items-center gap-3 p-4 hover:bg-accent rounded-lg transition-colors",
          unread? ? "bg-accent/50" : ""
        ]
      ) do
        Avatar do
          if @other_user.avatar_url.present?
            AvatarImage(src: @other_user.avatar_url, alt: @other_user.display_name)
          end
          AvatarFallback { user_initials }
        end

        div(class: "flex-1 min-w-0") do
          div(class: "flex items-center justify-between gap-2") do
            p(class: "font-medium truncate") { @other_user.display_name }
            if @last_message
              span(class: "text-xs text-muted-foreground flex-shrink-0") do
                time_ago(@last_message.created_at)
              end
            end
          end

          if @last_message
            p(class: [
              "text-sm truncate",
              unread? ? "text-foreground font-medium" : "text-muted-foreground"
            ]) do
              prefix = @last_message.sender_id == @current_user.id ? "You: " : ""
              "#{prefix}#{@last_message.content.truncate(50)}"
            end
          end
        end

        if unread?
          div(class: "w-2 h-2 bg-primary rounded-full flex-shrink-0")
        end
      end
    end

    private

    def other_participant
      if @conversation.participant_one_id == @current_user.id
        @conversation.participant_two
      else
        @conversation.participant_one
      end
    end

    def user_initials
      first = @other_user.first_name&.first&.upcase || ""
      last = @other_user.last_name&.first&.upcase || ""
      initials = "#{first}#{last}"
      initials.present? ? initials : @other_user.email_address&.first&.upcase || "U"
    end

    def unread?
      @conversation.messages
                   .where.not(sender: @current_user)
                   .where(read: false)
                   .exists?
    end

    def time_ago(time)
      diff = Time.current - time

      if diff < 60
        "now"
      elsif diff < 3600
        "#{(diff / 60).to_i}m"
      elsif diff < 86400
        "#{(diff / 3600).to_i}h"
      elsif diff < 604800
        "#{(diff / 86400).to_i}d"
      else
        time.strftime("%b %d")
      end
    end
    end
  end
end

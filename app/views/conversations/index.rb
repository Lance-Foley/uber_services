# frozen_string_literal: true

module Views
  module Conversations
    class Index < Views::Base
      def initialize(conversations:, current_user:)
        @conversations = conversations
        @current_user = current_user
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Messages"
        )

        if @conversations.any?
          Card do
            CardContent(class: "p-0") do
              div(class: "divide-y divide-border") do
                @conversations.each do |conversation|
                  render Components::Conversations::ConversationListItem.new(
                    conversation: conversation,
                    current_user: @current_user
                  )
                end
              end
            end
          end
        else
          render Components::Shared::EmptyState.new(
            icon: :chat,
            title: "No messages yet",
            description: "Messages with providers and customers will appear here."
          )
        end
      end
    end
  end
end

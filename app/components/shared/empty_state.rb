# frozen_string_literal: true

module Components
  module Shared
    class EmptyState < Components::Base
      def initialize(icon: :briefcase, title:, description: nil, action_text: nil, action_path: nil)
        @icon = icon
        @title = title
        @description = description
        @action_text = action_text
        @action_path = action_path
      end

      def view_template
        div(class: "text-center py-12") do
          div(class: "w-16 h-16 bg-muted rounded-full flex items-center justify-center mx-auto mb-4") do
            render icon_component
          end

          h3(class: "text-lg font-medium text-foreground mb-1") { @title }

          if @description
            p(class: "text-muted-foreground text-sm max-w-sm mx-auto") { @description }
          end

          if @action_text && @action_path
            div(class: "mt-6") do
              Link(href: @action_path, variant: :primary) { @action_text }
            end
          end
        end
      end

      private

      def icon_component
        case @icon
        when :briefcase then Components::Icons::Briefcase.new(size: :lg, class: "text-muted-foreground")
        when :home then Components::Icons::Home.new(size: :lg, class: "text-muted-foreground")
        when :chat then Components::Icons::ChatBubble.new(size: :lg, class: "text-muted-foreground")
        when :user then Components::Icons::User.new(size: :lg, class: "text-muted-foreground")
        when :search then Components::Icons::Search.new(size: :lg, class: "text-muted-foreground")
        when :clock then Components::Icons::Clock.new(size: :lg, class: "text-muted-foreground")
        when :map then Components::Icons::MapPin.new(size: :lg, class: "text-muted-foreground")
        when :bell then Components::Icons::Bell.new(size: :lg, class: "text-muted-foreground")
        when :star then Components::Icons::Star.new(size: :lg, class: "text-muted-foreground")
        when :inbox then Components::Icons::Inbox.new(size: :lg, class: "text-muted-foreground")
        when :calendar then Components::Icons::Calendar.new(size: :lg, class: "text-muted-foreground")
        else Components::Icons::Briefcase.new(size: :lg, class: "text-muted-foreground")
        end
      end
    end
  end
end

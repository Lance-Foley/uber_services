# frozen_string_literal: true

module Components
  module Navigation
    class BottomNavItem < Components::Base
      def initialize(path:, icon:, label:, active: false, badge: 0)
        @path = path
        @icon = icon
        @label = label
        @active = active
        @badge = badge
      end

      def view_template
        a(
          href: @path,
          class: [
            "flex flex-col items-center justify-center flex-1 py-2 relative",
            "transition-colors duration-200",
            @active ? "text-primary" : "text-muted-foreground hover:text-foreground"
          ],
          data: { turbo_frame: "_top" }
        ) do
          div(class: "relative") do
            render icon_component
            render_badge if @badge > 0
          end
          span(class: "text-xs mt-1 font-medium") { @label }
        end
      end

      private

      def icon_component
        case @icon
        when :home then Components::Icons::Home.new(size: :md)
        when :briefcase then Components::Icons::Briefcase.new(size: :md)
        when :chat then Components::Icons::ChatBubble.new(size: :md)
        when :user then Components::Icons::User.new(size: :md)
        when :search then Components::Icons::Search.new(size: :md)
        else Components::Icons::Home.new(size: :md)
        end
      end

      def render_badge
        span(
          class: [
            "absolute -top-1 -right-2 min-w-[18px] h-[18px] px-1",
            "flex items-center justify-center",
            "bg-destructive text-destructive-foreground text-xs font-medium rounded-full"
          ]
        ) { @badge > 99 ? "99+" : @badge.to_s }
      end
    end
  end
end

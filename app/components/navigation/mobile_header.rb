# frozen_string_literal: true

module Components
  module Navigation
    class MobileHeader < Components::Base
      def initialize(title: nil, show_back: false, back_path: nil)
        @title = title
        @show_back = show_back
        @back_path = back_path
      end

      def view_template
        header(
          class: [
            "sm:hidden", # Only show on mobile
            "fixed top-0 left-0 right-0 z-50",
            "bg-background border-b border-border",
            "h-14 flex items-center px-4"
          ],
          style: "padding-top: env(safe-area-inset-top)"
        ) do
          div(class: "flex items-center justify-between w-full") do
            render_left_section
            render_title if @title
            render_right_section
          end
        end
      end

      private

      def render_left_section
        div(class: "w-10") do
          if @show_back
            a(
              href: @back_path || "javascript:history.back()",
              class: "flex items-center justify-center w-10 h-10 -ml-2 rounded-full hover:bg-accent"
            ) do
              render Components::Icons::ChevronLeft.new(size: :md)
            end
          end
        end
      end

      def render_title
        h1(class: "flex-1 text-center text-lg font-semibold truncate") do
          @title
        end
      end

      def render_right_section
        div(class: "w-10") do
          # Placeholder for right action (notifications, menu, etc.)
        end
      end
    end
  end
end

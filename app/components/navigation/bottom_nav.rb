# frozen_string_literal: true

module Components
  module Navigation
    class BottomNav < Components::Base
      def initialize(current_user:, current_path:, unread_messages: 0, unread_notifications: 0)
        @current_user = current_user
        @current_path = current_path
        @unread_messages = unread_messages
        @unread_notifications = unread_notifications
      end

      def view_template
        nav(
          class: [
            "fixed bottom-0 left-0 right-0 z-50",
            "bg-background border-t border-border",
            "sm:hidden", # Hidden on tablet and above
            "pb-safe" # Safe area for iOS
          ],
          style: "padding-bottom: env(safe-area-inset-bottom)"
        ) do
          div(class: "flex items-center h-16") do
            nav_items.each do |item|
              render BottomNavItem.new(**item, active: active?(item[:path]))
            end
          end
        end
      end

      private

      def nav_items
        items = [
          { path: dashboard_path, icon: :home, label: "Home" },
          { path: jobs_path, icon: :briefcase, label: "Jobs" },
          { path: conversations_path, icon: :chat, label: "Messages", badge: @unread_messages },
          { path: profile_path, icon: :user, label: "Profile" }
        ]

        items
      end

      def jobs_path
        if @current_user.provider?
provider_my_jobs_path
        else
job_requests_path
        end
      rescue NoMethodError
dashboard_path
      end

      def active?(path)
        return false if path.blank?
        @current_path.to_s.start_with?(path.to_s.split("?").first)
      end
    end
  end
end

# frozen_string_literal: true

module Views
  module Notifications
    class Index < Views::Base
      def initialize(notifications:)
        @notifications = notifications
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Notifications",
          action: -> {
            if @notifications.any? { |n| !n.read? }
              form(action: mark_all_read_notifications_path, method: "post", class: "inline") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                Button(type: "submit", variant: :ghost, size: :sm) do
                  "Mark All Read"
                end
              end
            end
          }
        )

        if @notifications.any?
          Card do
            CardContent(class: "p-0") do
              div(class: "divide-y divide-border") do
                @notifications.each do |notification|
                  render_notification(notification)
                end
              end
            end
          end
        else
          render Components::Shared::EmptyState.new(
            icon: :bell,
            title: "No notifications",
            description: "You're all caught up!"
          )
        end
      end

      private

      def render_notification(notification)
        div(class: [
          "flex items-start gap-3 p-4",
          notification.read? ? "" : "bg-accent/50"
        ]) do
          div(class: [
            "w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0",
            notification_bg_class(notification.notification_type)
          ]) do
            render notification_icon(notification.notification_type)
          end

          div(class: "flex-1 min-w-0") do
            p(class: [
              "font-medium",
              notification.read? ? "text-muted-foreground" : ""
            ]) { notification.title }

            p(class: "text-sm text-muted-foreground") { notification.body }

            p(class: "text-xs text-muted-foreground mt-1") do
              time_ago(notification.created_at)
            end
          end

          unless notification.read?
            form(
              action: mark_read_notification_path(notification),
              method: "post",
              class: "flex-shrink-0"
            ) do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              button(type: "submit", class: "p-1 hover:bg-accent rounded") do
                render Components::Icons::Check.new(size: :xs, class: "text-muted-foreground")
              end
            end
          end
        end
      end

      def notification_bg_class(type)
        case type.to_s
        when "bid_received", "bid_accepted" then "bg-green-100 dark:bg-green-900/20"
        when "job_started", "job_completed" then "bg-blue-100 dark:bg-blue-900/20"
        when "payment_released" then "bg-green-100 dark:bg-green-900/20"
        when "new_message" then "bg-purple-100 dark:bg-purple-900/20"
        when "new_review" then "bg-yellow-100 dark:bg-yellow-900/20"
        else "bg-muted"
        end
      end

      def notification_icon(type)
        case type.to_s
        when "bid_received", "bid_accepted" then Components::Icons::CurrencyDollar.new(size: :sm, class: "text-green-600")
        when "job_started" then Components::Icons::Clock.new(size: :sm, class: "text-blue-600")
        when "job_completed" then Components::Icons::Check.new(size: :sm, class: "text-blue-600")
        when "payment_released" then Components::Icons::CurrencyDollar.new(size: :sm, class: "text-green-600")
        when "new_message" then Components::Icons::ChatBubble.new(size: :sm, class: "text-purple-600")
        when "new_review" then Components::Icons::Star.new(size: :sm, class: "text-yellow-600")
        else Components::Icons::Bell.new(size: :sm, class: "text-muted-foreground")
        end
      end

      def time_ago(time)
        diff = Time.current - time

        if diff < 60
          "Just now"
        elsif diff < 3600
          "#{(diff / 60).to_i} minutes ago"
        elsif diff < 86400
          "#{(diff / 3600).to_i} hours ago"
        elsif diff < 604800
          "#{(diff / 86400).to_i} days ago"
        else
          time.strftime("%b %d, %Y")
        end
      end
    end
  end
end

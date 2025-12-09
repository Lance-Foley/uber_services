# frozen_string_literal: true

module Views
  module Layouts
    class ApplicationLayout < Views::Base
      include Phlex::Rails::Layout

      def initialize(current_user: nil, current_path: nil, flash: {}, page_title: nil)
        @current_user = current_user
        @current_path = current_path
        @flash = flash
        @page_title = page_title
      end

      def view_template(&block)
        doctype
        html(lang: "en", class: "h-full") do
          render_head
          render_body(&block)
        end
      end

      private

      def render_head
        head do
          title { page_title }
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1, viewport-fit=cover")
          meta(name: "apple-mobile-web-app-capable", content: "yes")
          meta(name: "mobile-web-app-capable", content: "yes")
          meta(name: "theme-color", content: "#ffffff")
          csrf_meta_tags
          csp_meta_tag

          # Favicon
          link(rel: "icon", href: "/icon.png", type: "image/png")
          link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
          link(rel: "apple-touch-icon", href: "/icon.png")

          # Stylesheets and JavaScript
          stylesheet_link_tag(:tailwind, "data-turbo-track": "reload")
          stylesheet_link_tag(:application, "data-turbo-track": "reload")
          javascript_importmap_tags
        end
      end

      def render_body(&block)
        body(class: "min-h-full bg-background text-foreground antialiased") do
          if @current_user
            render_authenticated_layout(&block)
          else
            render_public_layout(&block)
          end
        end
      end

      def render_authenticated_layout(&block)
        # Flash messages
        render Components::Shared::FlashMessages.new(flash: @flash)

        # Desktop top navigation
        render Components::Navigation::TopNav.new(
          current_user: @current_user,
          current_path: @current_path
        )

        # Main content with proper spacing
        main(
          class: [
            "min-h-screen",
            "pt-0 sm:pt-16", # Top padding for desktop nav
            "pb-20 sm:pb-0" # Bottom padding for mobile nav
          ]
        ) do
          div(class: "container mx-auto px-4 sm:px-6 lg:px-8 py-6") do
            yield
          end
        end

        # Mobile bottom navigation
        render Components::Navigation::BottomNav.new(
          current_user: @current_user,
          current_path: @current_path,
          unread_messages: unread_messages_count,
          unread_notifications: unread_notifications_count
        )
      end

      def render_public_layout(&block)
        render Components::Shared::FlashMessages.new(flash: @flash)

        main(class: "min-h-screen") do
          yield
        end
      end

      def page_title
        [ @page_title, "Uber Services" ].compact.join(" | ")
      end

      def unread_messages_count
        return 0 unless @current_user
        # TODO: Implement actual count from database
        0
      end

      def unread_notifications_count
        return 0 unless @current_user
        # TODO: Implement actual count from database
        0
      end

      # Rails helper methods
      def csrf_meta_tags
        token = form_authenticity_token
        meta(name: "csrf-param", content: "authenticity_token")
        meta(name: "csrf-token", content: token)
      end

      def csp_meta_tag
        # CSP is typically handled by Rails headers, but we can add a meta tag if needed
      end

      def stylesheet_link_tag(name, **options)
        link(rel: "stylesheet", href: stylesheet_path(name), **options)
      end

      def javascript_importmap_tags
        # Render the importmap tags using Rails helpers
        raw super
      end
    end
  end
end

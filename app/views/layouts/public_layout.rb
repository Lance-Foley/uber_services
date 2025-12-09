# frozen_string_literal: true

module Views
  module Layouts
    class PublicLayout < Views::Base
      include Phlex::Rails::Layout

      def initialize(flash: {}, page_title: nil)
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
          stylesheet_link_tag(:application, "data-turbo-track": "reload")
          javascript_importmap_tags
        end
      end

      def render_body(&block)
        body(class: "min-h-full bg-background text-foreground antialiased") do
          render Components::Shared::FlashMessages.new(flash: @flash)

          main(class: "min-h-screen") do
            yield
          end
        end
      end

      def page_title
        [ @page_title, "Uber Services" ].compact.join(" | ")
      end

      # Rails helper methods
      def csrf_meta_tags
        token = form_authenticity_token
        meta(name: "csrf-param", content: "authenticity_token")
        meta(name: "csrf-token", content: token)
      end

      def csp_meta_tag
        # CSP is typically handled by Rails headers
      end

      def stylesheet_link_tag(name, **options)
        link(rel: "stylesheet", href: stylesheet_path(name), **options)
      end

      def javascript_importmap_tags
        unsafe_raw super
      end
    end
  end
end

# frozen_string_literal: true

module Components
  module Shared
    class PageHeader < Components::Base
      def initialize(title:, subtitle: nil, action: nil, back_path: nil)
        @title = title
        @subtitle = subtitle
        @action = action
        @back_path = back_path
      end

      def view_template
        div(class: "mb-6") do
          div(class: "flex items-start justify-between gap-4") do
            div(class: "flex-1 min-w-0") do
              if @back_path
                a(
                  href: @back_path,
                  class: "inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground mb-2"
                ) do
                  render Components::Icons::ChevronLeft.new(size: :xs)
                  span { "Back" }
                end
              end

              h1(class: "text-2xl sm:text-3xl font-bold text-foreground truncate") do
                @title
              end

              if @subtitle
                p(class: "text-muted-foreground mt-1") { @subtitle }
              end
            end

            if @action
              div(class: "flex-shrink-0") do
                @action.call
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Components
  module Shared
    class LoadingSpinner < Components::Base
      def initialize(size: :md, class_name: nil)
        @size = size
        @class_name = class_name
      end

      def view_template
        div(class: [ "flex items-center justify-center", @class_name ]) do
          svg(
            class: [ size_class, "animate-spin text-primary" ],
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24"
          ) do |s|
            s.circle(
              class: "opacity-25",
              cx: "12",
              cy: "12",
              r: "10",
              stroke: "currentColor",
              stroke_width: "4"
            )
            s.path(
              class: "opacity-75",
              fill: "currentColor",
              d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            )
          end
        end
      end

      private

      def size_class
        case @size
        when :xs then "w-4 h-4"
        when :sm then "w-5 h-5"
        when :md then "w-8 h-8"
        when :lg then "w-12 h-12"
        when :xl then "w-16 h-16"
        else "w-8 h-8"
        end
      end
    end
  end
end

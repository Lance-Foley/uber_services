# frozen_string_literal: true

module Components
  module Reviews
    class StarRatingInput < Components::Base
    def initialize(name:, value: 0, required: true)
      @name = name
      @value = value
      @required = required
    end

    def view_template
      div(
        class: "flex items-center gap-1",
        data: { controller: "star-rating" }
      ) do
        (1..5).each do |i|
          label(class: "cursor-pointer") do
            input(
              type: "radio",
              name: @name,
              value: i,
              class: "sr-only peer",
              required: @required && i == 1,
              checked: @value == i,
              data: { action: "change->star-rating#update" }
            )
            span(
              class: [
                "block transition-colors",
                i <= @value ? "text-yellow-500" : "text-muted-foreground hover:text-yellow-400"
              ],
              data: { star_rating_target: "star", value: i }
            ) do
              render Components::Icons::StarSolid.new(size: :lg)
            end
          end
        end
      end
    end
    end
  end
end

# frozen_string_literal: true

module Components
  module Reviews
    class RatingDisplay < Components::Base
    def initialize(rating:, size: :sm, show_count: false, count: 0)
      @rating = rating.to_f
      @size = size
      @show_count = show_count
      @count = count
    end

    def view_template
      div(class: "flex items-center gap-1") do
        (1..5).each do |i|
          if i <= @rating.floor
            render Components::Icons::StarSolid.new(size: @size, class: "text-yellow-500")
          elsif i - 0.5 <= @rating
            # Half star - simplified to filled for now
            render Components::Icons::StarSolid.new(size: @size, class: "text-yellow-500")
          else
            render Components::Icons::Star.new(size: @size, class: "text-muted-foreground")
          end
        end

        span(class: "text-sm text-muted-foreground ml-1") do
          format("%.1f", @rating)
        end

        if @show_count && @count > 0
          span(class: "text-sm text-muted-foreground") do
            "(#{@count})"
          end
        end
      end
    end
    end
  end
end

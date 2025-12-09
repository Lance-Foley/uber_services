# frozen_string_literal: true

module Components
  module JobRequests
    class JobRequestCard < Components::Base
    def initialize(job_request:, show_actions: true)
      @job_request = job_request
      @show_actions = show_actions
    end

    def view_template
      Card(class: "mb-4") do
        CardHeader do
          div(class: "flex items-center justify-between") do
            div do
              CardTitle(class: "text-base") { @job_request.service_type&.name || "Service Request" }
              CardDescription do
                "#{@job_request.property&.address_line_1}, #{@job_request.property&.city}"
              end
            end
            render JobStatusBadge.new(status: @job_request.status)
          end
        end

        CardContent do
          div(class: "grid grid-cols-2 gap-4 text-sm") do
            div do
              span(class: "text-muted-foreground block") { "Date" }
              p(class: "font-medium") { @job_request.requested_date&.strftime("%b %d, %Y") || "Flexible" }
            end

            div do
              span(class: "text-muted-foreground block") { "Urgency" }
              render UrgencyBadge.new(urgency: @job_request.urgency)
            end

            if @job_request.final_price
              div do
                span(class: "text-muted-foreground block") { "Price" }
                p(class: "font-semibold text-lg") { number_to_currency(@job_request.final_price) }
              end
            elsif @job_request.estimated_price
              div do
                span(class: "text-muted-foreground block") { "Est. Price" }
                p(class: "font-medium") { number_to_currency(@job_request.estimated_price) }
              end
            end

            if @job_request.provider
              div do
                span(class: "text-muted-foreground block") { "Provider" }
                p(class: "font-medium") { @job_request.provider.display_name }
              end
            elsif @job_request.open_for_bids?
              div do
                span(class: "text-muted-foreground block") { "Bids" }
                p(class: "font-medium") { "#{@job_request.job_bids.count} received" }
              end
            end
          end
        end

        if @show_actions
          CardFooter(class: "flex justify-end") do
            Link(href: job_request_path(@job_request), variant: :outline, size: :sm) do
              span { "View Details" }
              render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
            end
          end
        end
      end
    end
    end
  end
end

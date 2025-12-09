# frozen_string_literal: true

module Components
  module Bids
    class BidCard < Components::Base
    def initialize(bid:, job_request:, show_actions: true)
      @bid = bid
      @job_request = job_request
      @show_actions = show_actions
      @provider = bid.provider
      @profile = @provider.provider_profile
    end

    def view_template
      Card(class: "mb-4") do
        CardHeader do
          div(class: "flex items-start justify-between") do
            div(class: "flex items-center gap-3") do
              Avatar do
                if @provider.avatar_url.present?
                  AvatarImage(src: @provider.avatar_url, alt: @provider.display_name)
                end
                AvatarFallback { provider_initials }
              end

              div do
                CardTitle(class: "text-base") { @profile&.business_name || @provider.display_name }
                div(class: "flex items-center gap-2 text-sm text-muted-foreground") do
                  render_rating
                  span { "#{@profile&.completed_jobs || 0} jobs" }
                end
              end
            end

            div(class: "text-right") do
              p(class: "text-2xl font-bold text-primary") { number_to_currency(@bid.bid_amount) }
              if @bid.estimated_arrival.present?
                p(class: "text-sm text-muted-foreground") do
                  "Arrives #{@bid.estimated_arrival.strftime('%I:%M %p')}"
                end
              end
            end
          end
        end

        if @bid.message.present?
          CardContent do
            p(class: "text-sm text-muted-foreground italic") do
              "\"#{@bid.message}\""
            end
          end
        end

        if @show_actions && @job_request.open_for_bids?
          CardFooter(class: "flex justify-between gap-2") do
            Link(href: job_request_bid_path(@job_request, @bid), variant: :outline, size: :sm) do
              "View Profile"
            end

            div(class: "flex gap-2") do
              form(action: reject_job_request_bid_path(@job_request, @bid), method: "post", class: "inline") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                Button(type: "submit", variant: :ghost, size: :sm) { "Decline" }
              end

              form(action: accept_job_request_bid_path(@job_request, @bid), method: "post", class: "inline") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                Button(type: "submit", variant: :primary, size: :sm) { "Accept Bid" }
              end
            end
          end
        end
      end
    end

    private

    def render_rating
      rating = @profile&.average_rating || 0
      div(class: "flex items-center gap-1") do
        render Components::Icons::StarSolid.new(size: :xs, class: "text-yellow-500")
        span { format("%.1f", rating) }
      end
    end

    def provider_initials
      first = @provider.first_name&.first&.upcase || ""
      last = @provider.last_name&.first&.upcase || ""
      initials = "#{first}#{last}"
      initials.present? ? initials : @provider.email_address&.first&.upcase || "P"
    end
    end
  end
end

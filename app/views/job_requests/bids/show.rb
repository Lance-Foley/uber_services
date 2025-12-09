# frozen_string_literal: true

module Views
  module JobRequests
    module Bids
      class Show < Views::Base
        def initialize(job_request:, bid:, provider:, provider_profile:)
          @job_request = job_request
          @bid = bid
          @provider = provider
          @profile = provider_profile
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: @profile&.business_name || @provider.display_name,
            back_path: job_request_bids_path(@job_request)
          )

          # Provider profile card
          Card(class: "mb-6") do
            CardHeader do
              div(class: "flex items-center gap-4") do
                Avatar(size: :lg) do
                  if @provider.avatar_url.present?
                    AvatarImage(src: @provider.avatar_url, alt: @provider.display_name)
                  end
                  AvatarFallback { provider_initials }
                end

                div(class: "flex-1") do
                  CardTitle { @profile&.business_name || @provider.display_name }
                  div(class: "flex items-center gap-4 mt-1") do
                    render_rating
                    span(class: "text-sm text-muted-foreground") do
                      "#{@profile&.completed_jobs || 0} jobs completed"
                    end
                  end
                end
              end
            end

            if @profile&.bio.present?
              CardContent do
                p(class: "text-muted-foreground") { @profile.bio }
              end
            end
          end

          # Bid details card
          Card(class: "mb-6") do
            CardHeader do
              CardTitle { "Bid Details" }
            end

            CardContent do
              dl(class: "space-y-4") do
                detail_row("Bid Amount", number_to_currency(@bid.bid_amount), highlight: true)

                if @bid.estimated_arrival.present?
                  detail_row("Estimated Arrival", @bid.estimated_arrival.strftime("%B %d at %I:%M %p"))
                end

                if @bid.estimated_duration_minutes.present?
                  detail_row("Estimated Duration", pluralize(@bid.estimated_duration_minutes, "minute"))
                end

                if @bid.message.present?
                  div do
                    dt(class: "text-sm font-medium text-muted-foreground mb-1") { "Message" }
                    dd(class: "text-sm italic") { "\"#{@bid.message}\"" }
                  end
                end
              end
            end
          end

          # Actions
          if @job_request.open_for_bids?
            Card do
              CardContent(class: "pt-6") do
                div(class: "flex flex-col gap-3") do
                  form(action: accept_job_request_bid_path(@job_request, @bid), method: "post") do
                    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                    Button(type: "submit", variant: :primary, class: "w-full") do
                      "Accept This Bid"
                    end
                  end

                  form(action: reject_job_request_bid_path(@job_request, @bid), method: "post") do
                    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                    Button(type: "submit", variant: :outline, class: "w-full") do
                      "Decline Bid"
                    end
                  end

                  # Message provider button
                  Link(
                    href: conversations_path(recipient_id: @provider.id, job_request_id: @job_request.id),
                    variant: :ghost,
                    class: "w-full"
                  ) do
                    render Components::Icons::ChatBubble.new(size: :sm, class: "mr-2")
                    plain "Message Provider"
                  end
                end
              end
            end
          end
        end

        private

        def detail_row(label, value, highlight: false)
          div(class: "flex justify-between items-center") do
            dt(class: "text-sm text-muted-foreground") { label }
            dd(class: highlight ? "text-xl font-bold text-primary" : "text-sm font-medium") { value }
          end
        end

        def render_rating
          rating = @profile&.average_rating || 0
          div(class: "flex items-center gap-1") do
            render Components::Icons::StarSolid.new(size: :xs, class: "text-yellow-500")
            span(class: "text-sm font-medium") { format("%.1f", rating) }
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
end

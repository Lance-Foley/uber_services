# frozen_string_literal: true

module Views
  module Provider
    module Bids
      class New < Views::Base
        def initialize(job_request:, bid:, provider_service:)
          @job_request = job_request
          @bid = bid
          @provider_service = provider_service
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Submit Bid",
            back_path: provider_available_job_path(@job_request)
          )

          # Job summary
          Card(class: "mb-6") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                div do
                  CardTitle { @job_request.service_type.name }
                  CardDescription { @job_request.property&.display_address }
                end
                render Components::JobRequests::UrgencyBadge.new(urgency: @job_request.urgency)
              end
            end

            CardContent do
              dl(class: "grid grid-cols-2 gap-4 text-sm") do
                div do
                  dt(class: "text-muted-foreground") { "Requested Date" }
                  dd(class: "font-medium") { @job_request.requested_date&.strftime("%b %d, %Y") || "Flexible" }
                end

                if @job_request.property_size.present?
                  div do
                    dt(class: "text-muted-foreground") { "Property Size" }
                    dd(class: "font-medium") { @job_request.property_size.to_s.titleize }
                  end
                end
              end
            end
          end

          # Suggested pricing
          if @provider_service.present?
            Alert(class: "mb-6") do
              AlertTitle { "Your Pricing" }
              AlertDescription do
                case @provider_service.pricing_model
                when "flat_rate"
                  "Your base price for this service: #{number_to_currency(@provider_service.base_price)}"
                when "hourly"
                  "Your hourly rate: #{number_to_currency(@provider_service.hourly_rate)}/hr"
                when "per_sqft"
                  "Your rate: #{number_to_currency(@provider_service.base_price)}/sq ft"
                else
                  "Set your bid amount below"
                end
              end
            end
          end

          # Bid form
          Card do
            CardContent(class: "pt-6") do
              form(action: provider_available_job_bids_path(@job_request), method: "post", class: "space-y-6") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

                if @bid.errors.any?
                  Alert(variant: :destructive, class: "mb-4") do
                    AlertTitle { "Please fix the following errors:" }
                    AlertDescription do
                      ul(class: "list-disc list-inside") do
                        @bid.errors.full_messages.each do |msg|
                          li { msg }
                        end
                      end
                    end
                  end
                end

                FormField do
                  FormFieldLabel(for: "bid_amount") { "Bid Amount *" }
                  div(class: "relative") do
                    span(class: "absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground") { "$" }
                    Input(
                      type: "number",
                      id: "bid_amount",
                      name: "job_bid[bid_amount]",
                      value: @bid.bid_amount || @provider_service&.base_price,
                      step: "0.01",
                      min: "0",
                      required: true,
                      class: "pl-7"
                    )
                  end
                  FormFieldHint { "Enter your total price for this job" }
                end

                FormField do
                  FormFieldLabel(for: "estimated_arrival") { "Estimated Arrival" }
                  Input(
                    type: "datetime-local",
                    id: "estimated_arrival",
                    name: "job_bid[estimated_arrival]",
                    value: @bid.estimated_arrival&.strftime("%Y-%m-%dT%H:%M")
                  )
                  FormFieldHint { "When can you arrive to start the job?" }
                end

                FormField do
                  FormFieldLabel(for: "estimated_duration") { "Estimated Duration (minutes)" }
                  Input(
                    type: "number",
                    id: "estimated_duration",
                    name: "job_bid[estimated_duration_minutes]",
                    value: @bid.estimated_duration_minutes,
                    min: "0",
                    step: "15"
                  )
                  FormFieldHint { "How long will this job take?" }
                end

                FormField do
                  FormFieldLabel(for: "message") { "Message to Customer" }
                  Textarea(
                    id: "message",
                    name: "job_bid[message]",
                    rows: 3,
                    placeholder: "Introduce yourself and explain why you're a great fit for this job..."
                  ) { @bid.message }
                end

                Button(type: "submit", variant: :primary, class: "w-full") do
                  "Submit Bid"
                end
              end
            end
          end
        end
      end
    end
  end
end

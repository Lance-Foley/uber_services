# frozen_string_literal: true

module Views
  module Provider
    module AvailableJobs
      class Show < Views::Base
        def initialize(job_request:, my_bid:)
          @job_request = job_request
          @my_bid = my_bid
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: @job_request.service_type.name,
            back_path: provider_available_jobs_path
          )

          # Job Details Card
          render_job_details

          # Property Info
          render_property_info

          # Bid Section
          render_bid_section
        end

        private

        def render_job_details
          Card(class: "mb-6") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                CardTitle { "Job Details" }
                render Components::JobRequests::UrgencyBadge.new(urgency: @job_request.urgency)
              end
            end
            CardContent do
              dl(class: "space-y-4") do
                detail_item("Service", @job_request.service_type.name)
                detail_item("Date", @job_request.requested_date.strftime("%B %d, %Y"))

                if @job_request.requested_time_start
                  detail_item("Time", "#{@job_request.requested_time_start.strftime('%I:%M %p')} - #{@job_request.requested_time_end&.strftime('%I:%M %p')}")
                end

                detail_item("Flexible", @job_request.flexible_timing ? "Yes" : "No")

                if @job_request.description.present?
                  div do
                    dt(class: "text-sm text-muted-foreground") { "Description" }
                    dd(class: "mt-1") { @job_request.description }
                  end
                end
              end
            end
          end
        end

        def detail_item(label, value)
          div(class: "flex items-center justify-between") do
            dt(class: "text-sm text-muted-foreground") { label }
            dd(class: "font-medium") { value }
          end
        end

        def render_property_info
          property = @job_request.property

          Card(class: "mb-6") do
            CardHeader do
              CardTitle { "Property Information" }
            end
            CardContent do
              dl(class: "space-y-3") do
                div(class: "flex items-start gap-2") do
                  render Components::Icons::MapPin.new(size: :sm, class: "text-muted-foreground mt-0.5")
                  div do
                    p(class: "font-medium") { property.address_line_1 }
                    p(class: "text-sm text-muted-foreground") do
                      "#{property.city}, #{property.state} #{property.zip_code}"
                    end
                  end
                end

                detail_item("Property Size", property.property_size.humanize)

                if property.special_instructions.present?
                  div do
                    dt(class: "text-sm text-muted-foreground") { "Special Instructions" }
                    dd(class: "mt-1 text-sm") { property.special_instructions }
                  end
                end
              end
            end
          end
        end

        def render_bid_section
          if @my_bid
            render_my_bid
          else
            render_bid_form
          end
        end

        def render_my_bid
          Card do
            CardHeader do
              div(class: "flex items-center justify-between") do
                CardTitle { "Your Bid" }
                Badge(variant: bid_status_variant) { @my_bid.status.humanize }
              end
            end
            CardContent do
              div(class: "text-center py-4") do
                p(class: "text-3xl font-bold text-primary") { number_to_currency(@my_bid.bid_amount) }
                if @my_bid.estimated_arrival.present?
                  p(class: "text-sm text-muted-foreground mt-2") do
                    "Arrival: #{@my_bid.estimated_arrival.strftime('%I:%M %p')}"
                  end
                end
              end
            end

            if @my_bid.pending?
              CardFooter do
                form(
                  action: provider_available_job_bid_path(@job_request),
                  method: "post",
                  class: "w-full",
                  data: { turbo_confirm: "Are you sure you want to withdraw your bid?" }
                ) do
                  input(type: "hidden", name: "_method", value: "delete")
                  input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                  Button(type: "submit", variant: :destructive, class: "w-full") do
                    "Withdraw Bid"
                  end
                end
              end
            end
          end
        end

        def render_bid_form
          Card do
            CardHeader do
              CardTitle { "Submit Your Bid" }
              CardDescription { "Enter your price and estimated arrival time" }
            end
            CardContent do
              form(action: provider_available_job_bid_path(@job_request), method: "post", class: "space-y-6") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

                FormField do
                  FormFieldLabel(for: "job_bid_bid_amount") { "Your Price ($)" }
                  Input(
                    type: "number",
                    id: "job_bid_bid_amount",
                    name: "job_bid[bid_amount]",
                    step: "0.01",
                    min: "1",
                    required: true,
                    placeholder: "0.00"
                  )
                  FormFieldHint { "You'll receive 85% after platform fees" }
                end

                FormField do
                  FormFieldLabel(for: "job_bid_estimated_arrival") { "Estimated Arrival Time" }
                  Input(
                    type: "time",
                    id: "job_bid_estimated_arrival",
                    name: "job_bid[estimated_arrival]"
                  )
                end

                FormField do
                  FormFieldLabel(for: "job_bid_estimated_duration_minutes") { "Estimated Duration (minutes)" }
                  Input(
                    type: "number",
                    id: "job_bid_estimated_duration_minutes",
                    name: "job_bid[estimated_duration_minutes]",
                    min: "15",
                    step: "15",
                    placeholder: "60"
                  )
                end

                FormField do
                  FormFieldLabel(for: "job_bid_message") { "Message to Customer (optional)" }
                  Textarea(
                    id: "job_bid_message",
                    name: "job_bid[message]",
                    rows: 3,
                    placeholder: "Introduce yourself and explain why you're the right choice..."
                  )
                end

                Button(type: "submit", variant: :primary, class: "w-full") do
                  "Submit Bid"
                end
              end
            end
          end
        end

        def bid_status_variant
          case @my_bid.status
          when "pending" then :secondary
          when "accepted" then :success
          when "rejected" then :destructive
          else nil
          end
        end
      end
    end
  end
end

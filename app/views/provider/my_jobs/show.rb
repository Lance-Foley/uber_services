# frozen_string_literal: true

module Views
  module Provider
    module MyJobs
      class Show < Views::Base
        def initialize(job_request:, consumer:, review:)
          @job_request = job_request
          @consumer = consumer
          @review = review
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: @job_request.service_type.name,
            back_path: provider_my_jobs_path
          )

          # Status Card
          render_status_card

          # Customer Info
          render_customer_info

          # Job Details
          render_job_details

          # Property Info
          render_property_info

          # Actions
          render_actions
        end

        private

        def render_status_card
          Card(class: "mb-6") do
            CardContent(class: "pt-6") do
              div(class: "flex items-center justify-between") do
                div do
                  p(class: "text-sm text-muted-foreground") { "Status" }
                  div(class: "mt-1") do
                    render Components::JobRequests::JobStatusBadge.new(status: @job_request.status)
                  end
                end

                div(class: "text-right") do
                  p(class: "text-sm text-muted-foreground") { "Your Payout" }
                  p(class: "text-2xl font-bold text-green-600") do
                    number_to_currency(@job_request.provider_payout)
                  end
                end
              end
            end
          end
        end

        def render_customer_info
          Card(class: "mb-6") do
            CardHeader do
              CardTitle { "Customer" }
            end
            CardContent do
              div(class: "flex items-center gap-4") do
                Avatar(size: :lg) do
                  if @consumer.avatar_url.present?
                    AvatarImage(src: @consumer.avatar_url, alt: @consumer.display_name)
                  end
                  AvatarFallback { consumer_initials }
                end

                div(class: "flex-1") do
                  p(class: "font-semibold") { @consumer.display_name }
                  if @consumer.phone_number.present?
                    p(class: "text-sm text-muted-foreground") { @consumer.phone_number }
                  end
                end

                Link(
                  href: conversations_path(user_id: @consumer.id),
                  variant: :outline,
                  size: :sm
                ) do
                  render Components::Icons::ChatBubble.new(size: :sm, class: "mr-1")
                  span { "Message" }
                end
              end
            end
          end
        end

        def render_job_details
          Card(class: "mb-6") do
            CardHeader do
              CardTitle { "Job Details" }
            end
            CardContent do
              dl(class: "space-y-3") do
                detail_item("Service", @job_request.service_type.name)
                detail_item("Date", @job_request.requested_date.strftime("%B %d, %Y"))

                if @job_request.requested_time_start
                  detail_item("Time", "#{@job_request.requested_time_start.strftime('%I:%M %p')} - #{@job_request.requested_time_end&.strftime('%I:%M %p')}")
                end

                detail_item("Price", number_to_currency(@job_request.final_price))
                detail_item("Platform Fee", number_to_currency(@job_request.platform_fee))

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

        def render_property_info
          property = @job_request.property

          Card(class: "mb-6") do
            CardHeader do
              CardTitle { "Property" }
            end
            CardContent do
              div(class: "flex items-start gap-2") do
                render Components::Icons::MapPin.new(size: :sm, class: "text-muted-foreground mt-0.5")
                div do
                  p(class: "font-medium") { property.address_line_1 }
                  p(class: "text-sm text-muted-foreground") do
                    "#{property.city}, #{property.state} #{property.zip_code}"
                  end
                end
              end

              if property.special_instructions.present?
                div(class: "mt-4 p-3 bg-muted rounded-lg") do
                  p(class: "text-sm font-medium") { "Special Instructions" }
                  p(class: "text-sm text-muted-foreground mt-1") { property.special_instructions }
                end
              end
            end
          end
        end

        def render_actions
          Card do
            CardContent(class: "pt-6") do
              case @job_request.status
              when "accepted", "payment_authorized"
                form(action: start_provider_my_job_path(@job_request), method: "post", class: "w-full") do
                  input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                  Button(type: "submit", variant: :primary, class: "w-full") do
                    render Components::Icons::Check.new(size: :sm, class: "mr-2")
                    span { "Start Job" }
                  end
                end

              when "in_progress"
                form(action: complete_provider_my_job_path(@job_request), method: "post", class: "w-full") do
                  input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                  Button(type: "submit", variant: :primary, class: "w-full") do
                    render Components::Icons::Check.new(size: :sm, class: "mr-2")
                    span { "Mark Complete" }
                  end
                end

              when "completed", "payment_released"
                if @review
                  div(class: "text-center py-4") do
                    render Components::Icons::Check.new(size: :lg, class: "text-green-600 mx-auto mb-2")
                    p(class: "font-medium") { "Review Submitted" }
                    p(class: "text-sm text-muted-foreground") { "Thanks for your feedback!" }
                  end
                else
                  Link(
                    href: new_provider_my_job_review_path(@job_request),
                    variant: :primary,
                    class: "w-full justify-center"
                  ) do
                    render Components::Icons::Star.new(size: :sm, class: "mr-2")
                    span { "Leave Review" }
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

        def consumer_initials
          first = @consumer.first_name&.first&.upcase || ""
          last = @consumer.last_name&.first&.upcase || ""
          initials = "#{first}#{last}"
          initials.present? ? initials : @consumer.email_address&.first&.upcase || "C"
        end
      end
    end
  end
end

# frozen_string_literal: true

module Views
  module JobRequests
    class Show < Views::Base
      def initialize(job_request:, bids:, current_user: nil)
        @job_request = job_request
        @bids = bids
        @current_user = current_user
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: @job_request.service_type&.name || "Job Request",
          back_path: job_requests_path
        )

        # Status Card
        render_status_card

        # Job Details
        render_details_card

        # Bids Section (if open for bids)
        render_bids_section if @job_request.open_for_bids? && @bids.any?

        # Provider Info (if accepted)
        render_provider_info if @job_request.provider.present?

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

              if @job_request.final_price
                div(class: "text-right") do
                  p(class: "text-sm text-muted-foreground") { "Price" }
                  p(class: "text-2xl font-bold") { number_to_currency(@job_request.final_price) }
                end
              end
            end
          end
        end
      end

      def render_details_card
        Card(class: "mb-6") do
          CardHeader do
            CardTitle { "Details" }
          end
          CardContent do
            dl(class: "space-y-4") do
              detail_item("Service", @job_request.service_type&.name)
              detail_item("Property", @job_request.property&.address_line_1)
              detail_item("Date", @job_request.requested_date&.strftime("%B %d, %Y"))

              if @job_request.requested_time_start && @job_request.requested_time_end
                detail_item("Time", "#{@job_request.requested_time_start.strftime('%I:%M %p')} - #{@job_request.requested_time_end.strftime('%I:%M %p')}")
              end

              div(class: "flex items-center gap-2") do
                dt(class: "text-sm text-muted-foreground w-24") { "Urgency" }
                dd { render Components::JobRequests::UrgencyBadge.new(urgency: @job_request.urgency) }
              end

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
        div(class: "flex items-center gap-2") do
          dt(class: "text-sm text-muted-foreground w-24") { label }
          dd(class: "font-medium") { value || "—" }
        end
      end

      def render_bids_section
        Card(class: "mb-6") do
          CardHeader do
            div(class: "flex items-center justify-between") do
              CardTitle { "Bids Received" }
              Badge { "#{@bids.count} bids" }
            end
          end
          CardContent do
            div(class: "space-y-4") do
              @bids.each do |bid|
                render Components::Bids::BidCard.new(bid: bid, job_request: @job_request)
              end
            end
          end
        end
      end

      def render_provider_info
        provider = @job_request.provider
        profile = provider.provider_profile

        Card(class: "mb-6") do
          CardHeader do
            CardTitle { "Your Provider" }
          end
          CardContent do
            div(class: "flex items-center gap-4") do
              Avatar(size: :lg) do
                if provider.avatar_url.present?
                  AvatarImage(src: provider.avatar_url, alt: provider.display_name)
                end
                AvatarFallback { provider_initials(provider) }
              end

              div(class: "flex-1") do
                p(class: "font-semibold") { profile&.business_name || provider.display_name }
                div(class: "flex items-center gap-2 text-sm text-muted-foreground") do
                  render Components::Reviews::RatingDisplay.new(rating: profile&.average_rating || 0)
                  span { "#{profile&.completed_jobs || 0} jobs completed" }
                end
              end

              Link(href: conversations_path(user_id: provider.id), variant: :outline, size: :sm) do
                render Components::Icons::ChatBubble.new(size: :sm, class: "mr-1")
                span { "Message" }
              end
            end
          end
        end
      end

      def render_actions
        return unless can_modify?

        Card do
          CardContent(class: "pt-6") do
            div(class: "flex flex-col sm:flex-row gap-3") do
              if @job_request.pending? || @job_request.open_for_bids?
                Link(href: edit_job_request_path(@job_request), variant: :outline, class: "flex-1 justify-center") do
                  render Components::Icons::Pencil.new(size: :sm, class: "mr-1")
                  span { "Edit Request" }
                end
              end

              if @job_request.may_cancel?
                form(
                  action: job_request_path(@job_request),
                  method: "post",
                  class: "flex-1",
                  data: { turbo_confirm: "Are you sure you want to cancel this job request?" }
                ) do
                  input(type: "hidden", name: "_method", value: "delete")
                  input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                  Button(type: "submit", variant: :destructive, class: "w-full") do
                    render Components::Icons::X.new(size: :sm, class: "mr-1")
                    span { "Cancel Request" }
                  end
                end
              end

              if @job_request.completed? || @job_request.payment_released?
                unless @job_request.reviews.exists?(reviewer_id: @current_user&.id)
                  Link(href: new_job_request_review_path(@job_request), variant: :primary, class: "flex-1 justify-center") do
                    render Components::Icons::Star.new(size: :sm, class: "mr-1")
                    span { "Leave Review" }
                  end
                end
              end
            end
          end
        end
      end

      def can_modify?
        @job_request.pending? || @job_request.open_for_bids? || @job_request.may_cancel? ||
          (@job_request.completed? || @job_request.payment_released?)
      end

      def provider_initials(provider)
        first = provider.first_name&.first&.upcase || ""
        last = provider.last_name&.first&.upcase || ""
        initials = "#{first}#{last}"
        initials.present? ? initials : provider.email_address&.first&.upcase || "P"
      end
    end
  end
end

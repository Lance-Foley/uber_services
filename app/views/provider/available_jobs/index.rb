# frozen_string_literal: true

module Views
  module Provider
    module AvailableJobs
      class Index < Views::Base
        def initialize(job_requests:, filter:)
          @job_requests = job_requests
          @filter = filter
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Available Jobs",
            subtitle: "Jobs in your service area"
          )

          # Filter Tabs
          Tabs(default: @filter, class: "mb-6") do
            TabsList(class: "grid grid-cols-4 w-full") do
              tab_link("all", "All")
              tab_link("urgent", "Urgent")
              tab_link("today", "Today")
              tab_link("this_week", "This Week")
            end
          end

          turbo_frame_tag "available_jobs_list" do
            if @job_requests.any?
              div(class: "space-y-4") do
                @job_requests.each do |job_request|
                  render_job_card(job_request)
                end
              end
            else
              render Components::Shared::EmptyState.new(
                icon: :search,
                title: "No jobs available",
                description: "Check back later for new job requests in your area."
              )
            end
          end
        end

        private

        def tab_link(value, label)
          a(
            href: provider_available_jobs_path(filter: value),
            class: [
              "inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1.5 text-sm font-medium",
              "ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2",
              @filter == value ? "bg-background text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
            ],
            data: { turbo_frame: "available_jobs_list" }
          ) { label }
        end

        def render_job_card(job)
          Card(class: "mb-4") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                div do
                  CardTitle(class: "text-base") { job.service_type.name }
                  CardDescription do
                    "#{job.property.city}, #{job.property.state}"
                  end
                end
                render Components::JobRequests::UrgencyBadge.new(urgency: job.urgency)
              end
            end

            CardContent do
              div(class: "grid grid-cols-2 gap-4 text-sm") do
                div do
                  span(class: "text-muted-foreground block") { "Date" }
                  p(class: "font-medium") { job.requested_date.strftime("%b %d, %Y") }
                end
                div do
                  span(class: "text-muted-foreground block") { "Property Size" }
                  p(class: "font-medium capitalize") { job.property.property_size }
                end
              end

              if job.description.present?
                p(class: "text-sm text-muted-foreground mt-3 line-clamp-2") do
                  job.description
                end
              end
            end

            CardFooter(class: "flex justify-between") do
              div(class: "text-sm text-muted-foreground") do
                "#{job.job_bids.count} bids"
              end
              Link(href: provider_available_job_path(job), variant: :primary, size: :sm) do
                span { "View & Bid" }
                render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
              end
            end
          end
        end
      end
    end
  end
end

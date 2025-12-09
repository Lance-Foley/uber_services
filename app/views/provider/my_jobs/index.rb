# frozen_string_literal: true

module Views
  module Provider
    module MyJobs
      class Index < Views::Base
        def initialize(job_requests:, filter:)
          @job_requests = job_requests
          @filter = filter
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "My Jobs"
          )

          # Filter Tabs
          Tabs(default: @filter, class: "mb-6") do
            TabsList(class: "grid grid-cols-4 w-full") do
              tab_link("active", "Active")
              tab_link("pending", "Pending")
              tab_link("completed", "Completed")
              tab_link("all", "All")
            end
          end

          turbo_frame_tag "my_jobs_list" do
            if @job_requests.any?
              div(class: "space-y-4") do
                @job_requests.each do |job_request|
                  render_job_card(job_request)
                end
              end
            else
              render Components::Shared::EmptyState.new(
                icon: :briefcase,
                title: empty_state_title,
                description: empty_state_description,
                action_text: "Find Jobs",
                action_path: provider_available_jobs_path
              )
            end
          end
        end

        private

        def tab_link(value, label)
          a(
            href: provider_my_jobs_path(filter: value),
            class: [
              "inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1.5 text-sm font-medium",
              "ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2",
              @filter == value ? "bg-background text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
            ],
            data: { turbo_frame: "my_jobs_list" }
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
                render Components::JobRequests::JobStatusBadge.new(status: job.status)
              end
            end

            CardContent do
              div(class: "grid grid-cols-2 gap-4 text-sm") do
                div do
                  span(class: "text-muted-foreground block") { "Date" }
                  p(class: "font-medium") { job.requested_date.strftime("%b %d, %Y") }
                end
                div do
                  span(class: "text-muted-foreground block") { "Customer" }
                  p(class: "font-medium") { job.consumer.display_name }
                end
                div do
                  span(class: "text-muted-foreground block") { "Price" }
                  p(class: "font-semibold") { number_to_currency(job.final_price) }
                end
                div do
                  span(class: "text-muted-foreground block") { "Your Payout" }
                  p(class: "font-semibold text-green-600") { number_to_currency(job.provider_payout) }
                end
              end
            end

            CardFooter(class: "flex justify-end") do
              Link(href: provider_my_job_path(job), variant: :outline, size: :sm) do
                span { "View Details" }
                render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
              end
            end
          end
        end

        def empty_state_title
          case @filter
          when "active" then "No active jobs"
          when "pending" then "No pending jobs"
          when "completed" then "No completed jobs"
          else "No jobs yet"
          end
        end

        def empty_state_description
          case @filter
          when "active" then "Jobs you're working on will appear here."
          when "pending" then "Accepted jobs awaiting start will appear here."
          when "completed" then "Your completed jobs will appear here."
          else "Browse available jobs and submit bids to get started."
          end
        end
      end
    end
  end
end

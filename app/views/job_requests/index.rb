# frozen_string_literal: true

module Views
  module JobRequests
    class Index < Views::Base
      def initialize(job_requests:, filter:)
        @job_requests = job_requests
        @filter = filter
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "My Jobs",
          action: -> {
            Link(href: new_job_request_path, variant: :primary) do
              render Components::Icons::Plus.new(size: :sm, class: "mr-1")
              span { "New Request" }
            end
          }
        )

        # Filter Tabs
        Tabs(default: @filter, class: "mb-6") do
          TabsList(class: "grid grid-cols-4 w-full") do
            tab_link("all", "All")
            tab_link("active", "Active")
            tab_link("pending", "Pending")
            tab_link("completed", "Completed")
          end
        end

        turbo_frame_tag "job_requests_list" do
          if @job_requests.any?
            div(class: "space-y-4") do
              @job_requests.each do |job_request|
                render Components::JobRequests::JobRequestCard.new(job_request: job_request)
              end
            end
          else
            render Components::Shared::EmptyState.new(
              icon: :briefcase,
              title: empty_state_title,
              description: empty_state_description,
              action_text: "New Request",
              action_path: new_job_request_path
            )
          end
        end
      end

      private

      def tab_link(value, label)
        a(
          href: job_requests_path(filter: value),
          class: [
            "inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1.5 text-sm font-medium",
            "ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2",
            @filter == value ? "bg-background text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
          ],
          data: { turbo_frame: "job_requests_list" }
        ) { label }
      end

      def empty_state_title
        case @filter
        when "active" then "No active jobs"
        when "pending" then "No pending jobs"
        when "completed" then "No completed jobs"
        else "No job requests yet"
        end
      end

      def empty_state_description
        case @filter
        when "active" then "Your active jobs will appear here."
        when "pending" then "Jobs waiting for bids will appear here."
        when "completed" then "Your completed jobs will appear here."
        else "Create your first job request to get started."
        end
      end
    end
  end
end

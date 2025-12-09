# frozen_string_literal: true

module Views
  module Properties
    class Show < Views::Base
      def initialize(property:)
        @property = property
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: @property.name || "Property Details",
          back_path: properties_path,
          action: -> {
            Link(href: edit_property_path(@property), variant: :outline) do
              render Components::Icons::Pencil.new(size: :sm, class: "mr-1")
              span { "Edit" }
            end
          }
        )

        render Components::Properties::PropertyCard.new(property: @property, show_actions: false)

        # Job History
        Card(class: "mt-6") do
          CardHeader do
            CardTitle { "Job History" }
          end
          CardContent do
            jobs = @property.job_requests.includes(:service_type).order(created_at: :desc).limit(5)

            if jobs.any?
              div(class: "space-y-3") do
                jobs.each do |job|
                  a(
                    href: job_request_path(job),
                    class: "flex items-center justify-between p-3 rounded-lg hover:bg-accent"
                  ) do
                    div do
                      p(class: "font-medium") { job.service_type&.name }
                      p(class: "text-sm text-muted-foreground") { job.created_at.strftime("%b %d, %Y") }
                    end
                    render Components::JobRequests::JobStatusBadge.new(status: job.status)
                  end
                end
              end
            else
              p(class: "text-muted-foreground text-center py-4") { "No jobs for this property yet." }
            end
          end
        end
      end
    end
  end
end

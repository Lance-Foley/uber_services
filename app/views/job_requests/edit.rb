# frozen_string_literal: true

module Views
  module JobRequests
    class Edit < Views::Base
      def initialize(job_request:, properties:, service_categories:)
        @job_request = job_request
        @properties = properties
        @service_categories = service_categories
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Edit Request",
          back_path: job_request_path(@job_request)
        )

        Card do
          CardContent(class: "pt-6") do
            render JobRequestForm.new(
              job_request: @job_request,
              properties: @properties,
              service_categories: @service_categories,
              url: job_request_path(@job_request),
              method: :patch
            )
          end
        end
      end
    end
  end
end

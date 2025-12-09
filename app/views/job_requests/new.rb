# frozen_string_literal: true

module Views
  module JobRequests
    class New < Views::Base
      def initialize(job_request:, properties:, service_categories:)
        @job_request = job_request
        @properties = properties
        @service_categories = service_categories
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Request a Service",
          subtitle: "Tell us what you need",
          back_path: job_requests_path
        )

        if @properties.empty?
          render_no_properties_alert
        else
          Card do
            CardContent(class: "pt-6") do
              render JobRequestForm.new(
                job_request: @job_request,
                properties: @properties,
                service_categories: @service_categories,
                url: job_requests_path
              )
            end
          end
        end
      end

      private

      def render_no_properties_alert
        Alert(variant: :warning, class: "mb-6") do
          AlertTitle { "Add a Property First" }
          AlertDescription do
            p { "You need to add a property before you can request a service." }
            div(class: "mt-4") do
              Link(href: new_property_path, variant: :primary, size: :sm) do
                span { "Add Property" }
              end
            end
          end
        end
      end
    end
  end
end

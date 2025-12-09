# frozen_string_literal: true

module Views
  module Provider
    module Services
      class Edit < Views::Base
        def initialize(provider_service:, service_categories:)
          @provider_service = provider_service
          @service_categories = service_categories
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Edit Service",
            back_path: provider_services_path
          )

          Card do
            CardContent(class: "pt-6") do
              render ServiceForm.new(
                provider_service: @provider_service,
                service_categories: @service_categories,
                url: provider_service_path(@provider_service),
                method: :patch
              )
            end
          end
        end
      end
    end
  end
end

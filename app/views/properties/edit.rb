# frozen_string_literal: true

module Views
  module Properties
    class Edit < Views::Base
      def initialize(property:)
        @property = property
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Edit Property",
          back_path: properties_path
        )

        Card do
          CardContent(class: "pt-6") do
            render PropertyForm.new(
              property: @property,
              url: property_path(@property),
              method: :patch
            )
          end
        end
      end
    end
  end
end

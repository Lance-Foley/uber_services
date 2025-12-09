# frozen_string_literal: true

module Views
  module Properties
    class New < Views::Base
      def initialize(property:)
        @property = property
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Add Property",
          back_path: properties_path
        )

        Card do
          CardContent(class: "pt-6") do
            render PropertyForm.new(property: @property, url: properties_path)
          end
        end
      end
    end
  end
end

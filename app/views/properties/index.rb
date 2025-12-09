# frozen_string_literal: true

module Views
  module Properties
    class Index < Views::Base
      def initialize(properties:)
        @properties = properties
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "My Properties",
          subtitle: "Manage the properties where you need services",
          action: -> {
            Link(href: new_property_path, variant: :primary) do
              render Components::Icons::Plus.new(size: :sm, class: "mr-1")
              span { "Add Property" }
            end
          }
        )

        if @properties.any?
          div(class: "space-y-4") do
            @properties.each do |property|
              render Components::Properties::PropertyCard.new(property: property)
            end
          end
        else
          render Components::Shared::EmptyState.new(
            icon: :home,
            title: "No properties yet",
            description: "Add your first property to start requesting services.",
            action_text: "Add Property",
            action_path: new_property_path
          )
        end
      end
    end
  end
end

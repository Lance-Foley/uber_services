# frozen_string_literal: true

module Views
  module Provider
    module Services
      class Index < Views::Base
        def initialize(services:)
          @services = services
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "My Services",
            action: -> {
              Link(href: new_provider_service_path, variant: :primary) do
                render Components::Icons::Plus.new(size: :sm, class: "mr-1")
                span { "Add Service" }
              end
            }
          )

          if @services.any?
            div(class: "space-y-4") do
              @services.each do |service|
                render_service_card(service)
              end
            end
          else
            render Components::Shared::EmptyState.new(
              icon: :briefcase,
              title: "No services configured",
              description: "Add services you want to offer to customers.",
              action_text: "Add Service",
              action_path: new_provider_service_path
            )
          end
        end

        private

        def render_service_card(service)
          Card(class: "mb-4") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                CardTitle(class: "text-base") { service.service_type.name }
                Badge(variant: service.active? ? :success : :secondary) do
                  service.active? ? "Active" : "Inactive"
                end
              end
              CardDescription { service.service_type.service_category.name }
            end

            CardContent do
              div(class: "space-y-2") do
                div(class: "flex items-center justify-between text-sm") do
                  span(class: "text-muted-foreground") { "Pricing Model" }
                  span(class: "font-medium capitalize") { service.pricing_model.humanize }
                end

                div(class: "flex items-center justify-between text-sm") do
                  span(class: "text-muted-foreground") { "Price" }
                  span(class: "font-medium") { format_price(service) }
                end

                if service.notes.present?
                  p(class: "text-sm text-muted-foreground italic mt-2") do
                    "Note: #{service.notes.truncate(100)}"
                  end
                end
              end
            end

            CardFooter(class: "flex justify-end gap-2") do
              Link(href: edit_provider_service_path(service), variant: :outline, size: :sm) do
                render Components::Icons::Pencil.new(size: :xs, class: "mr-1")
                span { "Edit" }
              end

              form(
                action: provider_service_path(service),
                method: "post",
                class: "inline",
                data: { turbo_confirm: "Are you sure you want to remove this service?" }
              ) do
                input(type: "hidden", name: "_method", value: "delete")
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                Button(type: "submit", variant: :ghost, size: :sm, class: "text-destructive") do
                  render Components::Icons::Trash.new(size: :xs)
                end
              end
            end
          end
        end

        def format_price(service)
          case service.pricing_model
          when "hourly"
            "#{number_to_currency(service.hourly_rate)}/hr"
          when "per_job"
            number_to_currency(service.base_price)
          when "property_size"
            "By property size"
          else
            "Custom"
          end
        end
      end
    end
  end
end

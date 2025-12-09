# frozen_string_literal: true

module Views
  module Provider
    module Services
      class ServiceForm < Views::Base
        def initialize(provider_service:, service_categories:, url:, method: :post)
          @provider_service = provider_service
          @service_categories = service_categories
          @url = url
          @method = method
        end

        def view_template
          form(action: @url, method: "post", class: "space-y-6") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "_method", value: @method.to_s) if @method != :post

            if @provider_service.errors.any?
              Alert(variant: :destructive, class: "mb-4") do
                AlertTitle { "Please fix the following errors:" }
                AlertDescription do
                  ul(class: "list-disc list-inside") do
                    @provider_service.errors.full_messages.each do |msg|
                      li { msg }
                    end
                  end
                end
              end
            end

            # Service Type Selection
            FormField do
              FormFieldLabel { "Service Type" }
              div(class: "space-y-4") do
                @service_categories.each do |category|
                  next if category.service_types.empty?

                  div(class: "space-y-2") do
                    p(class: "text-sm font-medium text-muted-foreground") { category.name }
                    div(class: "grid grid-cols-1 sm:grid-cols-2 gap-2") do
                      category.service_types.active.each do |service_type|
                        label(class: [
                          "flex items-center gap-3 p-3 border rounded-lg cursor-pointer transition-colors",
                          "hover:bg-accent",
                          @provider_service.service_type_id == service_type.id ? "border-primary bg-primary/5" : "border-border"
                        ]) do
                          input(
                            type: "radio",
                            name: "provider_service[service_type_id]",
                            value: service_type.id,
                            checked: @provider_service.service_type_id == service_type.id,
                            required: true,
                            class: "sr-only"
                          )
                          span(class: "text-sm font-medium") { service_type.name }
                        end
                      end
                    end
                  end
                end
              end
            end

            # Pricing Model
            FormField do
              FormFieldLabel(for: "provider_service_pricing_model") { "Pricing Model" }
              pricing_labels = {
                "hourly" => "Hourly Rate",
                "per_job" => "Per Job (Flat Rate)",
                "property_size" => "By Property Size"
              }
              current_pricing = @provider_service.pricing_model || "hourly"
              Select(class: "w-full") do
                SelectInput(
                  name: "provider_service[pricing_model]",
                  id: "provider_service_pricing_model",
                  value: current_pricing
                )
                SelectTrigger do
                  SelectValue(placeholder: "Select pricing model") { pricing_labels[current_pricing] }
                end
                SelectContent do
                  SelectItem(value: "hourly") { "Hourly Rate" }
                  SelectItem(value: "per_job") { "Per Job (Flat Rate)" }
                  SelectItem(value: "property_size") { "By Property Size" }
                end
              end
            end

            # Hourly Rate
            FormField do
              FormFieldLabel(for: "provider_service_hourly_rate") { "Hourly Rate ($)" }
              Input(
                type: "number",
                id: "provider_service_hourly_rate",
                name: "provider_service[hourly_rate]",
                value: @provider_service.hourly_rate,
                step: "0.01",
                min: "0",
                placeholder: "25.00"
              )
              FormFieldHint { "For hourly pricing model" }
            end

            # Base Price
            FormField do
              FormFieldLabel(for: "provider_service_base_price") { "Base Price ($)" }
              Input(
                type: "number",
                id: "provider_service_base_price",
                name: "provider_service[base_price]",
                value: @provider_service.base_price,
                step: "0.01",
                min: "0",
                placeholder: "50.00"
              )
              FormFieldHint { "For per-job pricing model" }
            end

            # Minimum Charge
            FormField do
              FormFieldLabel(for: "provider_service_min_charge") { "Minimum Charge ($)" }
              Input(
                type: "number",
                id: "provider_service_min_charge",
                name: "provider_service[min_charge]",
                value: @provider_service.min_charge,
                step: "0.01",
                min: "0",
                placeholder: "25.00"
              )
            end

            # Notes
            FormField do
              FormFieldLabel(for: "provider_service_notes") { "Notes (optional)" }
              Textarea(
                id: "provider_service_notes",
                name: "provider_service[notes]",
                rows: 3,
                placeholder: "Any additional details about this service..."
              ) { @provider_service.notes }
            end

            # Active Toggle
            div(class: "flex items-center gap-2") do
              Checkbox(
                id: "provider_service_active",
                name: "provider_service[active]",
                value: "1",
                checked: @provider_service.active? || @provider_service.new_record?
              )
              label(for: "provider_service_active", class: "text-sm") do
                "Active (visible to customers)"
              end
            end

            # Submit
            div(class: "flex justify-end gap-3 pt-4") do
              Link(href: provider_services_path, variant: :outline) { "Cancel" }
              Button(type: "submit", variant: :primary) do
                @provider_service.new_record? ? "Add Service" : "Save Changes"
              end
            end
          end
        end
      end
    end
  end
end

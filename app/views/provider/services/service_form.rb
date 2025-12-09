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
          form(action: @url, method: "post", class: "space-y-6", data: { controller: "shared--conditional-fields" }) do
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
                        render_service_type_radio(service_type)
                      end
                    end
                  end
                end
              end
              render_field_error(:service_type_id)
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
                  value: current_pricing,
                  data: {
                    shared__conditional_fields_target: "source",
                    action: "change->shared--conditional-fields#toggle"
                  }
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
              render_field_error(:pricing_model)
            end

            # Hourly Rate (shown for hourly pricing)
            div(
              data: {
                shared__conditional_fields_target: "field",
                show_when: "hourly"
              }
            ) do
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
                FormFieldHint { "Your rate per hour of work" }
                render_field_error(:hourly_rate)
              end
            end

            # Base Price (shown for per_job and property_size)
            div(
              data: {
                shared__conditional_fields_target: "field",
                show_when: "per_job,property_size"
              }
            ) do
              FormField do
                FormFieldLabel(for: "provider_service_base_price") { "Base Price ($)" }
                Input(
                  type: "number",
                  id: "provider_service_base_price",
                  name: "provider_service[base_price]",
                  value: @provider_service.base_price,
                  step: "0.01",
                  min: "0",
                  placeholder: "50.00",
                  required: true
                )
                FormFieldHint { "Fixed price for this service" }
                render_field_error(:base_price)
              end
            end

            # Minimum Charge (shown for hourly and per_job)
            div(
              data: {
                shared__conditional_fields_target: "field",
                show_when: "hourly,per_job"
              }
            ) do
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
                FormFieldHint { "Minimum amount you'll charge for this service" }
                render_field_error(:min_charge)
              end
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
              render_field_error(:notes)
            end

            # Active Toggle
            div(class: "flex items-center gap-2") do
              input(type: "hidden", name: "provider_service[active]", value: "0")
              Checkbox(
                id: "provider_service_active",
                name: "provider_service[active]",
                value: "1",
                checked: @provider_service.active? || @provider_service.new_record?
              )
              label(for: "provider_service_active", class: "text-sm cursor-pointer") do
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

        private

        def render_service_type_radio(service_type)
          label(class: [
            "flex items-center gap-3 p-3 border rounded-lg cursor-pointer transition-colors",
            "hover:bg-accent hover:border-accent-foreground/20",
            "has-[:checked]:border-primary has-[:checked]:bg-primary/5 has-[:checked]:ring-1 has-[:checked]:ring-primary",
            "has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-ring has-[:focus-visible]:ring-offset-2",
            @provider_service.service_type_id == service_type.id ? "border-primary bg-primary/5" : "border-border"
          ]) do
            input(
              type: "radio",
              name: "provider_service[service_type_id]",
              value: service_type.id,
              checked: @provider_service.service_type_id == service_type.id,
              required: true,
              class: "sr-only",
              data: {
                ruby_ui__form_field_target: "input",
                action: "change->ruby-ui--form-field#onChange"
              }
            )
            div(class: "flex items-center gap-2") do
              # Visual indicator
              div(class: [
                "w-4 h-4 rounded-full border-2 flex items-center justify-center transition-colors",
                @provider_service.service_type_id == service_type.id ? "border-primary" : "border-muted-foreground"
              ]) do
                if @provider_service.service_type_id == service_type.id
                  div(class: "w-2 h-2 rounded-full bg-primary")
                end
              end
              span(class: "text-sm font-medium") { service_type.name }
            end
          end
        end

        def render_field_error(field)
          return unless has_error?(field)

          FormFieldError { @provider_service.errors[field].first }
        end

        def has_error?(field)
          @provider_service.errors[field].any?
        end
      end
    end
  end
end

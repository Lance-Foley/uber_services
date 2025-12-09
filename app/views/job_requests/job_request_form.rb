# frozen_string_literal: true

module Views
  module JobRequests
    class JobRequestForm < Views::Base
      def initialize(job_request:, properties:, service_categories:, url:, method: :post)
        @job_request = job_request
        @properties = properties
        @service_categories = service_categories
        @url = url
        @method = method
      end

      def view_template
        form(action: @url, method: "post", class: "space-y-6") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "_method", value: @method.to_s) if @method != :post

          if @job_request.errors.any?
            Alert(variant: :destructive, class: "mb-4") do
              AlertTitle { "Please fix the following errors:" }
              AlertDescription do
                ul(class: "list-disc list-inside") do
                  @job_request.errors.full_messages.each do |msg|
                    li { msg }
                  end
                end
              end
            end
          end

          # Property Selection
          FormField do
            FormFieldLabel(for: "job_request_property_id") { "Property" }
            selected_property = @properties.find { |p| p.id == @job_request.property_id }
            Select(class: "w-full") do
              SelectInput(
                name: "job_request[property_id]",
                id: "job_request_property_id",
                value: @job_request.property_id,
                required: true
              )
              SelectTrigger do
                SelectValue(placeholder: "Select a property") do
                  if selected_property
                    "#{selected_property.name || selected_property.address_line_1} - #{selected_property.city}"
                  end
                end
              end
              SelectContent do
                @properties.each do |property|
                  SelectItem(value: property.id.to_s) do
                    "#{property.name || property.address_line_1} - #{property.city}"
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
                  div(class: "grid grid-cols-2 gap-2") do
                    category.service_types.active.each do |service_type|
                      label(class: [
                        "flex items-center gap-3 p-3 border rounded-lg cursor-pointer transition-colors",
                        "hover:bg-accent",
                        @job_request.service_type_id == service_type.id ? "border-primary bg-primary/5" : "border-border"
                      ]) do
                        input(
                          type: "radio",
                          name: "job_request[service_type_id]",
                          value: service_type.id,
                          checked: @job_request.service_type_id == service_type.id,
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

          # Title
          FormField do
            FormFieldLabel(for: "job_request_title") { "Title (optional)" }
            Input(
              type: "text",
              id: "job_request_title",
              name: "job_request[title]",
              value: @job_request.title,
              placeholder: "Brief description of what you need"
            )
          end

          # Description
          FormField do
            FormFieldLabel(for: "job_request_description") { "Description (optional)" }
            Textarea(
              id: "job_request_description",
              name: "job_request[description]",
              rows: 3,
              placeholder: "Any additional details providers should know..."
            ) { @job_request.description }
          end

          # Date and Time
          div(class: "grid grid-cols-1 sm:grid-cols-2 gap-4") do
            FormField do
              FormFieldLabel(for: "job_request_requested_date") { "Preferred Date" }
              Input(
                type: "date",
                id: "job_request_requested_date",
                name: "job_request[requested_date]",
                value: @job_request.requested_date&.to_s,
                min: Date.current.to_s,
                required: true
              )
            end

            FormField do
              FormFieldLabel(for: "job_request_urgency") { "Urgency" }
              urgency_labels = { "normal" => "Normal", "urgent" => "Urgent (+25%)", "emergency" => "Emergency (+50%)" }
              current_urgency = @job_request.urgency || "normal"
              Select(class: "w-full") do
                SelectInput(
                  name: "job_request[urgency]",
                  id: "job_request_urgency",
                  value: current_urgency
                )
                SelectTrigger do
                  SelectValue(placeholder: "Select urgency") { urgency_labels[current_urgency] }
                end
                SelectContent do
                  SelectItem(value: "normal") { "Normal" }
                  SelectItem(value: "urgent") { "Urgent (+25%)" }
                  SelectItem(value: "emergency") { "Emergency (+50%)" }
                end
              end
            end
          end

          # Flexible Timing
          div(class: "flex items-center gap-2") do
            Checkbox(
              id: "job_request_flexible_timing",
              name: "job_request[flexible_timing]",
              value: "1",
              checked: @job_request.flexible_timing
            )
            label(for: "job_request_flexible_timing", class: "text-sm") do
              "I'm flexible on timing"
            end
          end

          # Submit
          div(class: "flex justify-end gap-3 pt-4") do
            Link(href: job_requests_path, variant: :outline) { "Cancel" }
            Button(type: "submit", variant: :primary) do
              @job_request.new_record? ? "Create Request" : "Save Changes"
            end
          end
        end
      end
    end
  end
end

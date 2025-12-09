# frozen_string_literal: true

module Views
  module Properties
    class PropertyForm < Views::Base
      def initialize(property:, url:, method: :post)
        @property = property
        @url = url
        @method = method
      end

      def view_template
        form(action: @url, method: "post", class: "space-y-6") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "_method", value: @method.to_s) if @method != :post

          if @property.errors.any?
            Alert(variant: :destructive, class: "mb-4") do
              AlertTitle { "Please fix the following errors:" }
              AlertDescription do
                ul(class: "list-disc list-inside") do
                  @property.errors.full_messages.each do |msg|
                    li { msg }
                  end
                end
              end
            end
          end

          # Property Name
          FormField do
            FormFieldLabel(for: "property_name") { "Property Name (optional)" }
            Input(
              type: "text",
              id: "property_name",
              name: "property[name]",
              value: @property.name,
              placeholder: "e.g., Main House, Vacation Home"
            )
            FormFieldHint { "A friendly name to identify this property" }
          end

          # Address
          FormField do
            FormFieldLabel(for: "property_address_line_1") { "Street Address" }
            Input(
              type: "text",
              id: "property_address_line_1",
              name: "property[address_line_1]",
              value: @property.address_line_1,
              required: true,
              placeholder: "123 Main Street"
            )
          end

          FormField do
            FormFieldLabel(for: "property_address_line_2") { "Apt, Suite, Unit (optional)" }
            Input(
              type: "text",
              id: "property_address_line_2",
              name: "property[address_line_2]",
              value: @property.address_line_2,
              placeholder: "Apt 4B"
            )
          end

          div(class: "grid grid-cols-2 gap-4") do
            FormField do
              FormFieldLabel(for: "property_city") { "City" }
              Input(
                type: "text",
                id: "property_city",
                name: "property[city]",
                value: @property.city,
                required: true
              )
            end

            FormField do
              FormFieldLabel(for: "property_state") { "State" }
              Input(
                type: "text",
                id: "property_state",
                name: "property[state]",
                value: @property.state,
                required: true,
                maxlength: 2,
                placeholder: "NY"
              )
            end
          end

          FormField do
            FormFieldLabel(for: "property_zip_code") { "ZIP Code" }
            Input(
              type: "text",
              id: "property_zip_code",
              name: "property[zip_code]",
              value: @property.zip_code,
              required: true,
              class: "max-w-[200px]"
            )
          end

          # Property Size
          FormField do
            FormFieldLabel(for: "property_property_size") { "Property Size" }
            size_labels = {
              "small" => "Small (under 0.25 acres)",
              "medium" => "Medium (0.25 - 0.5 acres)",
              "large" => "Large (0.5 - 1 acre)",
              "xlarge" => "Extra Large (over 1 acre)"
            }
            current_size = @property.property_size || "medium"
            Select(class: "w-full") do
              SelectInput(
                name: "property[property_size]",
                id: "property_property_size",
                value: current_size
              )
              SelectTrigger do
                SelectValue(placeholder: "Select size") { size_labels[current_size] }
              end
              SelectContent do
                SelectItem(value: "small") { "Small (under 0.25 acres)" }
                SelectItem(value: "medium") { "Medium (0.25 - 0.5 acres)" }
                SelectItem(value: "large") { "Large (0.5 - 1 acre)" }
                SelectItem(value: "xlarge") { "Extra Large (over 1 acre)" }
              end
            end
            FormFieldHint { "Helps providers estimate pricing" }
          end

          # Special Instructions
          FormField do
            FormFieldLabel(for: "property_special_instructions") { "Special Instructions (optional)" }
            Textarea(
              id: "property_special_instructions",
              name: "property[special_instructions]",
              rows: 3,
              placeholder: "Gate code, pet warnings, where to park, etc."
            ) { @property.special_instructions }
          end

          # Submit
          div(class: "flex justify-end gap-3 pt-4") do
            Link(href: properties_path, variant: :outline) { "Cancel" }
            Button(type: "submit", variant: :primary) do
              @property.new_record? ? "Add Property" : "Save Changes"
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Components
  module Properties
    class PropertyCard < Components::Base
    def initialize(property:, show_actions: true)
      @property = property
      @show_actions = show_actions
    end

    def view_template
      Card(class: "mb-4") do
        CardHeader do
          div(class: "flex items-center justify-between") do
            div(class: "flex items-center gap-3") do
              div(class: "w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center") do
                render Components::Icons::Building.new(size: :sm, class: "text-primary")
              end
              div do
                div(class: "flex items-center gap-2") do
                  CardTitle(class: "text-base") { @property.name || "Property" }
                  if @property.primary?
                    Badge(variant: :secondary, class: "text-xs") { "Primary" }
                  end
                end
                CardDescription { property_size_label }
              end
            end
          end
        end

        CardContent do
          div(class: "space-y-2 text-sm") do
            div(class: "flex items-start gap-2 text-muted-foreground") do
              render Components::Icons::MapPin.new(size: :sm)
              div do
                p { @property.address_line_1 }
                p { "#{@property.city}, #{@property.state} #{@property.zip_code}" }
              end
            end

            if @property.special_instructions.present?
              div(class: "text-muted-foreground italic") do
                "Note: #{@property.special_instructions.truncate(100)}"
              end
            end
          end
        end

        if @show_actions
          CardFooter(class: "flex justify-between gap-2") do
            div(class: "flex gap-2") do
              unless @property.primary?
                form(action: set_primary_property_path(@property), method: "post") do
                  input(type: "hidden", name: "_method", value: "patch")
                  input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                  Button(type: "submit", variant: :ghost, size: :sm) { "Set as Primary" }
                end
              end
            end

            div(class: "flex gap-2") do
              Link(href: edit_property_path(@property), variant: :outline, size: :sm) do
                render Components::Icons::Pencil.new(size: :xs)
                span(class: "ml-1") { "Edit" }
              end
            end
          end
        end
      end
    end

    private

    def property_size_label
      case @property.property_size
      when "small" then "Small Property"
      when "medium" then "Medium Property"
      when "large" then "Large Property"
      when "xlarge" then "Extra Large Property"
      else "Property"
      end
    end
    end
  end
end

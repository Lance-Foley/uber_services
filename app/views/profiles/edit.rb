# frozen_string_literal: true

module Views
  module Profiles
    class Edit < Views::Base
      def initialize(user:)
        @user = user
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Edit Profile",
          back_path: profile_path
        )

        Card do
          CardContent(class: "pt-6") do
            form(action: profile_path, method: "post", class: "space-y-6") do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              input(type: "hidden", name: "_method", value: "patch")

              if @user.errors.any?
                Alert(variant: :destructive, class: "mb-4") do
                  AlertTitle { "Please fix the following errors:" }
                  AlertDescription do
                    ul(class: "list-disc list-inside") do
                      @user.errors.full_messages.each do |msg|
                        li { msg }
                      end
                    end
                  end
                end
              end

              # Avatar preview
              div(class: "flex items-center gap-4 mb-6") do
                Avatar(size: :lg) do
                  if @user.avatar_url.present?
                    AvatarImage(src: @user.avatar_url, alt: @user.display_name)
                  end
                  AvatarFallback { user_initials }
                end
                div do
                  p(class: "font-medium") { @user.display_name }
                  p(class: "text-sm text-muted-foreground") { @user.email_address }
                end
              end

              div(class: "grid grid-cols-2 gap-4") do
                FormField do
                  FormFieldLabel(for: "user_first_name") { "First Name" }
                  Input(
                    type: "text",
                    id: "user_first_name",
                    name: "user[first_name]",
                    value: @user.first_name,
                    required: true
                  )
                end

                FormField do
                  FormFieldLabel(for: "user_last_name") { "Last Name" }
                  Input(
                    type: "text",
                    id: "user_last_name",
                    name: "user[last_name]",
                    value: @user.last_name,
                    required: true
                  )
                end
              end

              FormField do
                FormFieldLabel(for: "user_phone_number") { "Phone Number" }
                Input(
                  type: "tel",
                  id: "user_phone_number",
                  name: "user[phone_number]",
                  value: @user.phone_number,
                  placeholder: "(555) 123-4567"
                )
              end

              FormField do
                FormFieldLabel(for: "user_avatar_url") { "Avatar URL (optional)" }
                Input(
                  type: "url",
                  id: "user_avatar_url",
                  name: "user[avatar_url]",
                  value: @user.avatar_url,
                  placeholder: "https://example.com/avatar.jpg"
                )
                FormFieldHint { "Enter a URL to an image for your profile picture" }
              end

              # Submit
              div(class: "flex justify-end gap-3 pt-4") do
                Link(href: profile_path, variant: :outline) { "Cancel" }
                Button(type: "submit", variant: :primary) { "Save Changes" }
              end
            end
          end
        end
      end

      private

      def user_initials
        first = @user.first_name&.first&.upcase || ""
        last = @user.last_name&.first&.upcase || ""
        initials = "#{first}#{last}"
        initials.present? ? initials : @user.email_address&.first&.upcase || "U"
      end
    end
  end
end

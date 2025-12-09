# frozen_string_literal: true

module Views
  module Provider
    module Profile
      class Edit < Views::Base
        def initialize(profile:, user:)
          @profile = profile
          @user = user
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Edit Provider Profile",
            back_path: provider_profile_path
          )

          Card do
            CardContent(class: "pt-6") do
              form(action: provider_profile_path, method: "post", class: "space-y-6") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                input(type: "hidden", name: "_method", value: "patch")

                if @profile.errors.any?
                  Alert(variant: :destructive, class: "mb-4") do
                    AlertTitle { "Please fix the following errors:" }
                    AlertDescription do
                      ul(class: "list-disc list-inside") do
                        @profile.errors.full_messages.each do |msg|
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
                    p(class: "font-medium") { @profile.business_name || @user.display_name }
                    div(class: "flex items-center gap-2 text-sm text-muted-foreground") do
                      render Components::Reviews::RatingDisplay.new(rating: @profile.average_rating || 0)
                      span { "#{@profile.completed_jobs || 0} jobs completed" }
                    end
                  end
                end

                # Business Name
                FormField do
                  FormFieldLabel(for: "provider_profile_business_name") { "Business Name" }
                  Input(
                    type: "text",
                    id: "provider_profile_business_name",
                    name: "provider_profile[business_name]",
                    value: @profile.business_name,
                    required: true,
                    placeholder: "Your business or display name"
                  )
                  FormFieldHint { "This is how customers will see you" }
                end

                # Bio
                FormField do
                  FormFieldLabel(for: "provider_profile_bio") { "About Your Services" }
                  Textarea(
                    id: "provider_profile_bio",
                    name: "provider_profile[bio]",
                    rows: 4,
                    placeholder: "Describe your experience, equipment, and what makes you stand out..."
                  ) { @profile.bio }
                  FormFieldHint { "Help customers understand why they should choose you" }
                end

                # Service Radius
                FormField do
                  FormFieldLabel(for: "provider_profile_service_radius_miles") { "Service Radius (miles)" }
                  Input(
                    type: "number",
                    id: "provider_profile_service_radius_miles",
                    name: "provider_profile[service_radius_miles]",
                    value: @profile.service_radius_miles || 15,
                    min: 1,
                    max: 100,
                    required: true
                  )
                  FormFieldHint { "How far are you willing to travel for jobs?" }
                end

                # Accepting Jobs Toggle
                div(class: "flex items-center justify-between p-4 bg-muted/50 rounded-lg") do
                  div do
                    p(class: "font-medium") { "Accepting Jobs" }
                    p(class: "text-sm text-muted-foreground") { "Toggle to pause receiving new job requests" }
                  end
                  Switch(
                    id: "provider_profile_accepting_jobs",
                    name: "provider_profile[accepting_jobs]",
                    value: "1",
                    checked: @profile.accepting_jobs
                  )
                end

                # Stripe Account Status
                render_stripe_status

                # Submit
                div(class: "flex justify-end gap-3 pt-4") do
                  Link(href: provider_profile_path, variant: :outline) { "Cancel" }
                  Button(type: "submit", variant: :primary) { "Save Changes" }
                end
              end
            end
          end
        end

        private

        def render_stripe_status
          Card(class: "mt-6") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                CardTitle { "Payment Setup" }
                if @profile.stripe_onboarded?
                  Badge(variant: :success) { "Connected" }
                else
                  Badge(variant: :warning) { "Incomplete" }
                end
              end
            end
            CardContent do
              if @profile.stripe_onboarded?
                p(class: "text-sm text-muted-foreground") do
                  "Your Stripe account is connected. You'll receive payouts for completed jobs."
                end
              else
                p(class: "text-sm text-muted-foreground mb-4") do
                  "Connect your Stripe account to receive payments for completed jobs."
                end
                Link(href: provider_stripe_account_onboard_path, variant: :outline) do
                  render Components::Icons::CurrencyDollar.new(size: :sm, class: "mr-2")
                  span { "Connect Stripe Account" }
                end
              end
            end
          end
        end

        def user_initials
          first = @user.first_name&.first&.upcase || ""
          last = @user.last_name&.first&.upcase || ""
          initials = "#{first}#{last}"
          initials.present? ? initials : @user.email_address&.first&.upcase || "P"
        end
      end
    end
  end
end

# frozen_string_literal: true

module Views
  module Provider
    module Onboarding
      class Show < Views::Base
        def initialize(step:, provider_profile:, service_categories:)
          @step = step
          @provider_profile = provider_profile
          @service_categories = service_categories
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Become a Provider",
            subtitle: step_subtitle
          )

          # Progress indicator
          render_progress_indicator

          Card(class: "mt-6") do
            CardContent(class: "pt-6") do
              case @step
              when 1 then render_step_1
              when 2 then render_step_2
              when 3 then render_step_3
              when 4 then render_step_4
              when 5 then render_step_5
              else render_complete
              end
            end
          end
        end

        private

        def step_subtitle
          case @step
          when 1 then "Step 1: Create your profile"
          when 2 then "Step 2: Business information"
          when 3 then "Step 3: Set your service area"
          when 4 then "Step 4: Select your services"
          when 5 then "Step 5: Set up payments"
          else "Setup complete!"
          end
        end

        def render_progress_indicator
          div(class: "flex items-center justify-between mb-6") do
            (1..5).each do |i|
              div(class: "flex items-center") do
                div(class: [
                  "w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium",
                  if i < @step
                    "bg-primary text-primary-foreground"
                  elsif i == @step
                    "bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2"
                  else
                    "bg-muted text-muted-foreground"
                  end
                ]) do
                  if i < @step
                    render Components::Icons::Check.new(size: :xs)
                  else
                    i.to_s
                  end
                end

                if i < 5
                  div(class: [
                    "w-8 sm:w-16 h-1 mx-1",
                    i < @step ? "bg-primary" : "bg-muted"
                  ])
                end
              end
            end
          end
        end

        def render_step_1
          # Create profile - basic info
          form(action: provider_onboarding_path, method: "post", class: "space-y-6") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            FormField do
              FormFieldLabel(for: "provider_profile_business_name") { "Business Name" }
              Input(
                type: "text",
                id: "provider_profile_business_name",
                name: "provider_profile[business_name]",
                value: @provider_profile.business_name,
                required: true,
                placeholder: "Your business or display name"
              )
            end

            FormField do
              FormFieldLabel(for: "provider_profile_bio") { "Bio" }
              Textarea(
                id: "provider_profile_bio",
                name: "provider_profile[bio]",
                rows: 4,
                placeholder: "Tell customers about yourself and your experience..."
              ) { @provider_profile.bio }
            end

            Button(type: "submit", variant: :primary, class: "w-full") do
              span { "Continue" }
              render Components::Icons::ChevronRight.new(size: :sm, class: "ml-1")
            end
          end
        end

        def render_step_2
          # Business details
          form(action: provider_onboarding_path, method: "post", class: "space-y-6") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "_method", value: "patch")
            input(type: "hidden", name: "step", value: "2")

            FormField do
              FormFieldLabel(for: "provider_profile_business_name") { "Business Name" }
              Input(
                type: "text",
                id: "provider_profile_business_name",
                name: "provider_profile[business_name]",
                value: @provider_profile.business_name,
                required: true
              )
            end

            FormField do
              FormFieldLabel(for: "provider_profile_bio") { "About Your Services" }
              Textarea(
                id: "provider_profile_bio",
                name: "provider_profile[bio]",
                rows: 4,
                placeholder: "Describe your experience, equipment, and what makes you stand out..."
              ) { @provider_profile.bio }
            end

            Button(type: "submit", variant: :primary, class: "w-full") do
              span { "Continue" }
              render Components::Icons::ChevronRight.new(size: :sm, class: "ml-1")
            end
          end
        end

        def render_step_3
          # Service radius
          form(action: provider_onboarding_path, method: "post", class: "space-y-6") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "_method", value: "patch")
            input(type: "hidden", name: "step", value: "3")

            FormField do
              FormFieldLabel(for: "provider_profile_service_radius_miles") { "Service Radius (miles)" }
              Input(
                type: "number",
                id: "provider_profile_service_radius_miles",
                name: "provider_profile[service_radius_miles]",
                value: @provider_profile.service_radius_miles || 15,
                min: 1,
                max: 100,
                required: true
              )
              FormFieldHint { "How far are you willing to travel for jobs?" }
            end

            p(class: "text-sm text-muted-foreground") do
              "You'll only see job requests from properties within this distance of your location."
            end

            Button(type: "submit", variant: :primary, class: "w-full") do
              span { "Continue" }
              render Components::Icons::ChevronRight.new(size: :sm, class: "ml-1")
            end
          end
        end

        def render_step_4
          # Service selection - redirect to services page
          div(class: "text-center space-y-6") do
            div(class: "w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto") do
              render Components::Icons::Clipboard.new(size: :lg, class: "text-primary")
            end

            h3(class: "text-lg font-semibold") { "Select Your Services" }
            p(class: "text-muted-foreground") do
              "Choose which services you want to offer and set your pricing."
            end

            Link(href: provider_services_path, variant: :primary, class: "w-full justify-center") do
              span { "Configure Services" }
              render Components::Icons::ChevronRight.new(size: :sm, class: "ml-1")
            end
          end
        end

        def render_step_5
          # Stripe setup
          div(class: "text-center space-y-6") do
            div(class: "w-16 h-16 bg-green-100 dark:bg-green-900/20 rounded-full flex items-center justify-center mx-auto") do
              render Components::Icons::CurrencyDollar.new(size: :lg, class: "text-green-600")
            end

            h3(class: "text-lg font-semibold") { "Set Up Payments" }
            p(class: "text-muted-foreground") do
              "Connect your Stripe account to receive payments for completed jobs."
            end

            Link(href: provider_stripe_account_onboard_path, variant: :primary, class: "w-full justify-center") do
              span { "Connect Stripe Account" }
              render Components::Icons::ChevronRight.new(size: :sm, class: "ml-1")
            end
          end
        end

        def render_complete
          div(class: "text-center space-y-6") do
            div(class: "w-16 h-16 bg-green-100 dark:bg-green-900/20 rounded-full flex items-center justify-center mx-auto") do
              render Components::Icons::Check.new(size: :lg, class: "text-green-600")
            end

            h3(class: "text-lg font-semibold") { "You're All Set!" }
            p(class: "text-muted-foreground") do
              "Your provider profile is complete. Start browsing available jobs!"
            end

            Link(href: provider_available_jobs_path, variant: :primary, class: "w-full justify-center") do
              span { "Browse Jobs" }
              render Components::Icons::ChevronRight.new(size: :sm, class: "ml-1")
            end
          end
        end
      end
    end
  end
end

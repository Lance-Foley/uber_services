# frozen_string_literal: true

module Views
  module Profiles
    class Show < Views::Base
      def initialize(user:)
        @user = user
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Profile",
          action: -> {
            Link(href: edit_profile_path, variant: :outline) do
              render Components::Icons::Pencil.new(size: :sm, class: "mr-1")
              span { "Edit" }
            end
          }
        )

        # Profile Card
        Card(class: "mb-6") do
          CardContent(class: "pt-6") do
            div(class: "flex items-center gap-4") do
              Avatar(size: :lg) do
                if @user.avatar_url.present?
                  AvatarImage(src: @user.avatar_url, alt: @user.display_name)
                end
                AvatarFallback { user_initials }
              end

              div do
                h2(class: "text-xl font-semibold") { @user.display_name }
                p(class: "text-muted-foreground") { @user.email_address }
                if @user.phone_number.present?
                  p(class: "text-sm text-muted-foreground") { @user.phone_number }
                end
              end
            end
          end
        end

        # Quick Links
        Card(class: "mb-6") do
          CardContent(class: "p-0") do
            div(class: "divide-y divide-border") do
              profile_link(properties_path, "My Properties", Components::Icons::Building)
              profile_link(job_requests_path, "My Jobs", Components::Icons::Briefcase)
              profile_link(conversations_path, "Messages", Components::Icons::ChatBubble)
              profile_link(notifications_path, "Notifications", Components::Icons::Bell)
            end
          end
        end

        # Provider Section
        if @user.provider?
          render_provider_section
        else
          render_become_provider_section
        end

        # Sign Out
        Card(class: "mt-6") do
          CardContent(class: "pt-6") do
            form(action: session_path, method: "post") do
              input(type: "hidden", name: "_method", value: "delete")
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              Button(type: "submit", variant: :destructive, class: "w-full") do
                render Components::Icons::Logout.new(size: :sm, class: "mr-2")
                span { "Sign Out" }
              end
            end
          end
        end
      end

      private

      def profile_link(path, label, icon_class)
        a(
          href: path,
          class: "flex items-center justify-between p-4 hover:bg-accent transition-colors"
        ) do
          div(class: "flex items-center gap-3") do
            render icon_class.new(size: :sm, class: "text-muted-foreground")
            span { label }
          end
          render Components::Icons::ChevronRight.new(size: :sm, class: "text-muted-foreground")
        end
      end

      def render_provider_section
        profile = @user.provider_profile

        Card(class: "mb-6") do
          CardHeader do
            div(class: "flex items-center justify-between") do
              CardTitle { "Provider Profile" }
              Badge(variant: profile.accepting_jobs ? :success : :secondary) do
                profile.accepting_jobs ? "Accepting Jobs" : "Not Accepting"
              end
            end
          end
          CardContent do
            div(class: "space-y-3") do
              if profile.business_name.present?
                div do
                  p(class: "text-sm text-muted-foreground") { "Business Name" }
                  p(class: "font-medium") { profile.business_name }
                end
              end

              div(class: "flex items-center gap-4") do
                div do
                  p(class: "text-sm text-muted-foreground") { "Rating" }
                  render Components::Reviews::RatingDisplay.new(
                    rating: profile.average_rating,
                    show_count: true,
                    count: profile.total_reviews
                  )
                end
                div do
                  p(class: "text-sm text-muted-foreground") { "Jobs Completed" }
                  p(class: "font-medium") { profile.completed_jobs.to_s }
                end
              end
            end
          end
          CardFooter do
            Link(href: provider_profile_path, variant: :outline, class: "w-full justify-center") do
              span { "Go to Provider Dashboard" }
              render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
            end
          end
        end
      end

      def render_become_provider_section
        Card(class: "mb-6 border-dashed") do
          CardContent(class: "pt-6 text-center") do
            div(class: "w-12 h-12 bg-green-100 dark:bg-green-900/20 rounded-full flex items-center justify-center mx-auto mb-4") do
              render Components::Icons::CurrencyDollar.new(size: :md, class: "text-green-600")
            end
            h3(class: "font-semibold mb-1") { "Become a Provider" }
            p(class: "text-sm text-muted-foreground mb-4") do
              "Start earning money by providing services in your area."
            end
            Link(href: provider_onboarding_path, variant: :primary) do
              span { "Get Started" }
            end
          end
        end
      end

      def user_initials
        first = @user.first_name&.first&.upcase || ""
        last = @user.last_name&.first&.upcase || ""
        initials = "#{first}#{last}"
        initials.present? ? initials : @user.email_address&.first&.upcase || "U"
      end
    end
  end
end

# frozen_string_literal: true

module Views
  module Provider
    module Profile
      class Show < Views::Base
        def initialize(profile:, services:, recent_reviews:)
          @profile = profile
          @services = services
          @recent_reviews = recent_reviews
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Provider Dashboard",
            action: -> {
              Link(href: edit_provider_profile_path, variant: :outline) do
                render Components::Icons::Pencil.new(size: :sm, class: "mr-1")
                span { "Edit Profile" }
              end
            }
          )

          # Stats Overview
          render_stats_cards

          # Quick Actions
          render_quick_actions

          # My Services
          render_services_section

          # Recent Reviews
          render_reviews_section if @recent_reviews.any?
        end

        private

        def render_stats_cards
          div(class: "grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6") do
            stat_card("Rating", format("%.1f", @profile.average_rating), Components::Icons::Star)
            stat_card("Reviews", @profile.total_reviews.to_s, Components::Icons::ChatBubble)
            stat_card("Jobs", @profile.completed_jobs.to_s, Components::Icons::Briefcase)
            stat_card("Status", @profile.accepting_jobs ? "Active" : "Inactive", Components::Icons::Check)
          end
        end

        def stat_card(label, value, icon_class)
          Card do
            CardContent(class: "pt-4 pb-4") do
              div(class: "flex items-center gap-3") do
                div(class: "w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center") do
                  render icon_class.new(size: :sm, class: "text-primary")
                end
                div do
                  p(class: "text-2xl font-bold") { value }
                  p(class: "text-xs text-muted-foreground") { label }
                end
              end
            end
          end
        end

        def render_quick_actions
          div(class: "grid grid-cols-2 gap-4 mb-6") do
            Link(
              href: provider_available_jobs_path,
              variant: :outline,
              class: "h-auto py-4 flex-col gap-2"
            ) do
              render Components::Icons::Search.new(size: :md)
              span { "Find Jobs" }
            end

            Link(
              href: provider_my_jobs_path,
              variant: :outline,
              class: "h-auto py-4 flex-col gap-2"
            ) do
              render Components::Icons::Clipboard.new(size: :md)
              span { "My Jobs" }
            end
          end
        end

        def render_services_section
          Card(class: "mb-6") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                CardTitle { "My Services" }
                Link(href: new_provider_service_path, variant: :ghost, size: :sm) do
                  render Components::Icons::Plus.new(size: :xs, class: "mr-1")
                  span { "Add" }
                end
              end
            end
            CardContent do
              if @services.any?
                div(class: "space-y-3") do
                  @services.each do |service|
                    div(class: "flex items-center justify-between p-3 bg-muted/50 rounded-lg") do
                      div do
                        p(class: "font-medium") { service.service_type.name }
                        p(class: "text-sm text-muted-foreground") { pricing_label(service) }
                      end
                      Badge(variant: service.active? ? :success : :secondary) do
                        service.active? ? "Active" : "Inactive"
                      end
                    end
                  end
                end
              else
                render Components::Shared::EmptyState.new(
                  icon: :briefcase,
                  title: "No services configured",
                  description: "Add services to start receiving job requests.",
                  action_text: "Add Service",
                  action_path: new_provider_service_path
                )
              end
            end
          end
        end

        def render_reviews_section
          Card do
            CardHeader do
              CardTitle { "Recent Reviews" }
            end
            CardContent do
              div(class: "space-y-4") do
                @recent_reviews.each do |review|
                  div(class: "border-b border-border pb-4 last:border-0 last:pb-0") do
                    div(class: "flex items-center justify-between mb-2") do
                      div(class: "flex items-center gap-2") do
                        Avatar(size: :sm) do
                          AvatarFallback { review.reviewer.first_name&.first&.upcase || "U" }
                        end
                        span(class: "font-medium text-sm") { review.reviewer.display_name }
                      end
                      render Components::Reviews::RatingDisplay.new(rating: review.rating, size: :xs)
                    end
                    if review.comment.present?
                      p(class: "text-sm text-muted-foreground") { review.comment }
                    end
                    p(class: "text-xs text-muted-foreground mt-1") do
                      review.created_at.strftime("%b %d, %Y")
                    end
                  end
                end
              end
            end
          end
        end

        def pricing_label(service)
          case service.pricing_model
          when "hourly"
            "#{number_to_currency(service.hourly_rate)}/hr"
          when "per_job"
            "#{number_to_currency(service.base_price)} per job"
          when "property_size"
            "Varies by property size"
          else
            "Custom pricing"
          end
        end
      end
    end
  end
end

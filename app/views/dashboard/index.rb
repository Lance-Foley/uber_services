# frozen_string_literal: true

module Views
  module Dashboard
    class Index < Views::Base
      def initialize(user:)
        @user = user
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Welcome back, #{@user.first_name || 'there'}!",
          subtitle: "What would you like to do today?"
        )

        # Quick Actions
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 mb-8") do
          render_request_service_card
          render_provider_card
        end

        # Active Job Requests
        render_active_jobs

        # Recent Activity
        render_recent_activity
      end

      private

      def render_request_service_card
        Card(class: "hover:shadow-md transition-shadow") do
          CardHeader do
            div(class: "flex items-start gap-4") do
              div(class: "w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center flex-shrink-0") do
                render Components::Icons::Plus.new(size: :md, class: "text-primary")
              end
              div do
                CardTitle { "Request a Service" }
                CardDescription { "Need snow removal or lawn care? Create a new job request." }
              end
            end
          end
          CardFooter do
            Link(href: new_job_request_path, variant: :primary, size: :sm) do
              span { "Get Started" }
              render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
            end
          end
        end
      end

      def render_provider_card
        if @user.provider?
          render_provider_dashboard_card
        else
          render_become_provider_card
        end
      end

      def render_become_provider_card
        Card(class: "hover:shadow-md transition-shadow") do
          CardHeader do
            div(class: "flex items-start gap-4") do
              div(class: "w-12 h-12 bg-green-100 dark:bg-green-900/20 rounded-xl flex items-center justify-center flex-shrink-0") do
                render Components::Icons::CurrencyDollar.new(size: :md, class: "text-green-600")
              end
              div do
                CardTitle { "Earn Money as a Provider" }
                CardDescription { "Set up your provider profile and start accepting jobs." }
              end
            end
          end
          CardFooter do
            Link(href: provider_onboarding_path, variant: :outline, size: :sm) do
              span { "Set Up Profile" }
              render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
            end
          end
        end
      end

      def render_provider_dashboard_card
        Card(class: "hover:shadow-md transition-shadow") do
          CardHeader do
            div(class: "flex items-start gap-4") do
              div(class: "w-12 h-12 bg-green-100 dark:bg-green-900/20 rounded-xl flex items-center justify-center flex-shrink-0") do
                render Components::Icons::Clipboard.new(size: :md, class: "text-green-600")
              end
              div do
                CardTitle { "Provider Dashboard" }
                CardDescription { "View job requests, manage bids, and track earnings." }
              end
            end
          end
          CardFooter do
            Link(href: provider_profile_path, variant: :outline, size: :sm) do
              span { "View Dashboard" }
              render Components::Icons::ChevronRight.new(size: :xs, class: "ml-1")
            end
          end
        end
      end

      def render_active_jobs
        active_jobs = @user.consumer_job_requests
                          .where(status: %w[open_for_bids accepted payment_authorized in_progress])
                          .includes(:service_type, :property)
                          .order(created_at: :desc)
                          .limit(3)

        Card(class: "mb-6") do
          CardHeader do
            div(class: "flex items-center justify-between") do
              CardTitle { "Active Jobs" }
              if active_jobs.any?
                Link(href: job_requests_path(filter: "active"), variant: :ghost, size: :sm) do
                  "View All"
                end
              end
            end
          end
          CardContent do
            if active_jobs.any?
              div(class: "space-y-4") do
                active_jobs.each do |job|
                  render_job_item(job)
                end
              end
            else
              render Components::Shared::EmptyState.new(
                icon: :briefcase,
                title: "No active jobs",
                description: "Create a job request to get started.",
                action_text: "New Request",
                action_path: new_job_request_path
              )
            end
          end
        end
      end

      def render_job_item(job)
        a(
          href: job_request_path(job),
          class: "flex items-center justify-between p-3 rounded-lg hover:bg-accent transition-colors"
        ) do
          div(class: "flex items-center gap-3") do
            div(class: "w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center") do
              render Components::Icons::Briefcase.new(size: :sm, class: "text-primary")
            end
            div do
              p(class: "font-medium") { job.service_type&.name || "Service Request" }
              p(class: "text-sm text-muted-foreground") { job.requested_date&.strftime("%b %d, %Y") }
            end
          end
          render Components::JobRequests::JobStatusBadge.new(status: job.status)
        end
      end

      def render_recent_activity
        Card do
          CardHeader do
            CardTitle { "Recent Activity" }
          end
          CardContent do
            render Components::Shared::EmptyState.new(
              icon: :clock,
              title: "No recent activity",
              description: "Your job requests and updates will appear here."
            )
          end
        end
      end
    end
  end
end

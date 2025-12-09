# frozen_string_literal: true

module Components
  module Navigation
    class TopNav < Components::Base
    def initialize(current_user:, current_path:)
      @current_user = current_user
      @current_path = current_path
    end

    def view_template
      nav(
        class: [
          "hidden sm:block", # Only show on tablet and above
          "fixed top-0 left-0 right-0 z-50",
          "bg-background border-b border-border"
        ]
      ) do
        div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8") do
          div(class: "flex justify-between h-16") do
            render_logo
            render_nav_links
            render_user_menu
          end
        end
      end
    end

    private

    def render_logo
      div(class: "flex items-center") do
        a(href: dashboard_path, class: "flex items-center gap-2") do
          div(class: "w-8 h-8 bg-primary rounded-lg flex items-center justify-center") do
            render Components::Icons::Home.new(size: :sm, class: "text-primary-foreground")
          end
          span(class: "text-lg font-semibold text-foreground") { "Uber Services" }
        end
      end
    end

    def render_nav_links
      div(class: "flex items-center gap-1") do
        nav_links.each do |link|
          a(
            href: link[:path],
            class: [
              "px-3 py-2 text-sm font-medium rounded-md transition-colors",
              active?(link[:path]) ? "bg-accent text-accent-foreground" : "text-muted-foreground hover:text-foreground hover:bg-accent/50"
            ]
          ) { link[:label] }
        end
      end
    end

    def render_user_menu
      div(class: "flex items-center gap-4") do
        # Notifications link
        a(href: notifications_path, class: "relative p-2 rounded-md hover:bg-accent transition-colors") do
          render Components::Icons::Bell.new(size: :sm)
        end

        # User dropdown
        DropdownMenu do
          DropdownMenuTrigger(class: "flex items-center gap-2 p-2 rounded-lg hover:bg-accent cursor-pointer") do
            render_avatar
            render Components::Icons::ChevronDown.new(size: :xs, class: "text-muted-foreground")
          end

          DropdownMenuContent(class: "w-56") do
            render_user_info
            DropdownMenuSeparator()
            render_menu_items
            DropdownMenuSeparator()
            render_logout
          end
        end
      end
    end

    def render_avatar
      Avatar(size: :sm) do
        if @current_user.avatar_url.present?
          AvatarImage(src: @current_user.avatar_url, alt: @current_user.display_name)
        end
        AvatarFallback { user_initials }
      end
    end

    def render_user_info
      div(class: "px-2 py-1.5") do
        p(class: "text-sm font-medium") { @current_user.display_name }
        p(class: "text-xs text-muted-foreground truncate") { @current_user.email_address }
      end
    end

    def render_menu_items
      # Profile
      DropdownMenuItem do
        a(href: profile_path, class: "flex items-center gap-2 w-full") do
          render Components::Icons::User.new(size: :sm)
          span { "Profile" }
        end
      end

      # Properties
      DropdownMenuItem do
        a(href: properties_path, class: "flex items-center gap-2 w-full") do
          render Components::Icons::Building.new(size: :sm)
          span { "My Properties" }
        end
      end

      # Job Requests
      DropdownMenuItem do
        a(href: job_requests_path, class: "flex items-center gap-2 w-full") do
          render Components::Icons::Briefcase.new(size: :sm)
          span { "My Job Requests" }
        end
      end

      # Provider Dashboard (if provider)
      if @current_user.provider?
        DropdownMenuSeparator()
        DropdownMenuItem do
          a(href: provider_profile_path, class: "flex items-center gap-2 w-full") do
            render Components::Icons::Clipboard.new(size: :sm)
            span { "Provider Dashboard" }
          end
        end
      end

      # Admin Section (if admin)
      if @current_user.admin?
        DropdownMenuSeparator()
        DropdownMenuLabel(class: "flex items-center gap-2") do
          render Components::Icons::Shield.new(size: :sm)
          span { "Admin" }
        end

        DropdownMenuItem do
          a(href: admin_root_path, class: "flex items-center gap-2 w-full pl-6") do
            render Components::Icons::Home.new(size: :sm)
            span { "Dashboard" }
          end
        end

        DropdownMenuItem do
          a(href: admin_users_path, class: "flex items-center gap-2 w-full pl-6") do
            render Components::Icons::User.new(size: :sm)
            span { "Users" }
          end
        end

        DropdownMenuItem do
          a(href: admin_payments_path, class: "flex items-center gap-2 w-full pl-6") do
            render Components::Icons::CurrencyDollar.new(size: :sm)
            span { "Payments" }
          end
        end

        DropdownMenuItem do
          a(href: admin_job_requests_path, class: "flex items-center gap-2 w-full pl-6") do
            render Components::Icons::Briefcase.new(size: :sm)
            span { "Job Requests" }
          end
        end
      end
    end

    def render_logout
      DropdownMenuItem do
        form(action: session_path, method: "post", class: "w-full") do
          input(type: "hidden", name: "_method", value: "delete")
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          button(type: "submit", class: "flex items-center gap-2 w-full text-destructive") do
            render Components::Icons::Logout.new(size: :sm)
            span { "Sign out" }
          end
        end
      end
    end

    def nav_links
      links = [
        { path: dashboard_path, label: "Dashboard" }
      ]

      links << { path: job_requests_path, label: "My Jobs" }
      links << { path: conversations_path, label: "Messages" }

      if @current_user.provider?
        links << { path: provider_available_jobs_path, label: "Find Jobs" }
      end

      links
    rescue NoMethodError
      [ { path: dashboard_path, label: "Dashboard" } ]
    end

    def active?(path)
      return false if path.blank?
      @current_path.to_s.start_with?(path.to_s.split("?").first)
    end

    def user_initials
      first = @current_user.first_name&.first&.upcase || ""
      last = @current_user.last_name&.first&.upcase || ""
      initials = "#{first}#{last}"
      initials.present? ? initials : @current_user.email_address&.first&.upcase || "U"
    end
    end
  end
end

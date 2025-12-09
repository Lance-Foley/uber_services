# frozen_string_literal: true

module Provider
  class ProfileController < BaseController
    def show
      @profile = Current.user.provider_profile
      @services = @profile.provider_services.includes(:service_type).order(:created_at)
      @recent_reviews = Current.user.reviews_received.includes(:reviewer, :job_request).order(created_at: :desc).limit(5)
      @page_title = "Provider Dashboard"
      render Views::Provider::Profile::Show.new(
        profile: @profile,
        services: @services,
        recent_reviews: @recent_reviews
      ), layout: phlex_layout
    end

    def edit
      @profile = Current.user.provider_profile
      @page_title = "Edit Profile"
      render Views::Provider::Profile::Edit.new(
        profile: @profile,
        user: Current.user
      ), layout: phlex_layout
    end

    def update
      @profile = Current.user.provider_profile

      if @profile.update(profile_params)
        redirect_to provider_profile_path, notice: "Profile updated successfully."
      else
        @page_title = "Edit Profile"
        render Views::Provider::Profile::Edit.new(
          profile: @profile,
          user: Current.user
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:provider_profile).permit(
        :business_name, :bio, :service_radius_miles, :accepting_jobs,
        :availability_schedule
      )
    end
  end
end

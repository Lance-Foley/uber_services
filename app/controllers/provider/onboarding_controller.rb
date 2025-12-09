# frozen_string_literal: true

module Provider
  class OnboardingController < BaseController
    def show
      if Current.user.provider? && Current.user.provider_profile.stripe_charges_enabled?
        redirect_to provider_profile_path, notice: "You're all set up!"
        return
      end

      @step = determine_current_step
      @provider_profile = Current.user.provider_profile || Current.user.build_provider_profile
      @service_categories = ServiceCategory.where(active: true).includes(:service_types).order(:position)
      @page_title = "Become a Provider"
      render Views::Provider::Onboarding::Show.new(
        step: @step,
        provider_profile: @provider_profile,
        service_categories: @service_categories
      ), layout: phlex_layout
    end

    def create
      @provider_profile = Current.user.build_provider_profile(provider_profile_params)

      if @provider_profile.save
        redirect_to provider_onboarding_path, notice: "Profile created! Continue with setup."
      else
        @step = 1
        @service_categories = ServiceCategory.where(active: true).includes(:service_types).order(:position)
        @page_title = "Become a Provider"
        render Views::Provider::Onboarding::Show.new(
          step: @step,
          provider_profile: @provider_profile,
          service_categories: @service_categories
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    def update
      @provider_profile = Current.user.provider_profile

      if @provider_profile.update(provider_profile_params)
        if params[:step].to_i < 5
          redirect_to provider_onboarding_path, notice: "Progress saved!"
        else
          redirect_to provider_stripe_account_onboard_path, notice: "Almost done! Set up your payment account."
        end
      else
        @step = params[:step].to_i || determine_current_step
        @service_categories = ServiceCategory.where(active: true).includes(:service_types).order(:position)
        @page_title = "Become a Provider"
        render Views::Provider::Onboarding::Show.new(
          step: @step,
          provider_profile: @provider_profile,
          service_categories: @service_categories
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    private

    def determine_current_step
      profile = Current.user.provider_profile

      return 1 if profile.nil?
      return 2 if profile.business_name.blank?
      return 3 if profile.service_radius_miles.nil?
      return 4 if profile.provider_services.empty?
      return 5 unless profile.stripe_charges_enabled?
      6 # Complete
    end

    def provider_profile_params
      params.require(:provider_profile).permit(
        :business_name, :bio, :service_radius_miles, :accepting_jobs,
        :availability_schedule
      )
    end
  end
end

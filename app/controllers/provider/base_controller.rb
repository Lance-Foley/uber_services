# frozen_string_literal: true

module Provider
  class BaseController < ApplicationController
    before_action :require_provider_or_onboarding

    private

    def require_provider_or_onboarding
      # Allow access to onboarding for non-providers
      return if controller_name == "onboarding"

      unless Current.user.provider?
        redirect_to provider_onboarding_path, alert: "Please complete your provider setup first."
      end
    end

    def require_provider
      unless Current.user.provider?
        redirect_to provider_onboarding_path, alert: "Please complete your provider setup first."
      end
    end
  end
end

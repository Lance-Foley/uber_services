# frozen_string_literal: true

module Omniauth
  class SessionsController < ApplicationController
    skip_before_action :require_authentication
    allow_unauthenticated_access

    def create
      auth = request.env["omniauth.auth"]
      result = Oauth::CreateUserService.call(auth)

      if result.success?
        start_new_session_for(result.user)
        redirect_to after_authentication_url, notice: "Successfully signed in with #{auth.provider.titleize}!"
      else
        redirect_to new_session_path, alert: result.error
      end
    end

    def failure
      redirect_to new_session_path, alert: "Authentication failed: #{params[:message].humanize}"
    end

    private

    def after_authentication_url
      stored_location || root_path
    end

    def stored_location
      session.delete(:return_to)
    end
  end
end

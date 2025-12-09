# frozen_string_literal: true

class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    # Redirect authenticated users to their dashboard
    if authenticated?
      redirect_to dashboard_path
    end
  end
end

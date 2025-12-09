# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?
  end

  private

  def admin?
    Current.user&.admin?
  end

  def require_admin
    unless admin?
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end
end

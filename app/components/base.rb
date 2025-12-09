# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include RubyUI
  include Components::Icons
  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::TurboFrameTag

  # Add form/asset helpers
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags

  # Register value helpers that return data (not HTML)
  register_value_helper :form_authenticity_token
  register_value_helper :stylesheet_path

  # Add number formatting helpers
  include ActionView::Helpers::NumberHelper
  # Add text helpers for pluralize, etc.
  include ActionView::Helpers::TextHelper

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end

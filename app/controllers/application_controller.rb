class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # Render a Phlex view with the application layout
  def render_phlex(view_class, **locals)
    render view_class.new(**locals), layout: phlex_layout
  end

  def phlex_layout
    ->(*) {
      Views::Layouts::ApplicationLayout.new(
        current_user: Current.user,
        current_path: request.path,
        flash: flash.to_h,
        page_title: @page_title
      )
    }
  end

  def phlex_public_layout
    ->(*) {
      Views::Layouts::PublicLayout.new(
        flash: flash.to_h,
        page_title: @page_title
      )
    }
  end
end

# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @page_title = "Dashboard"
    render Views::Dashboard::Index.new(user: Current.user), layout: phlex_layout
  end
end

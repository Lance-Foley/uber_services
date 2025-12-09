# frozen_string_literal: true

module Provider
  class AvailableJobsController < BaseController
    def index
      @page_title = "Available Jobs"
      @filter = params[:filter] || "all"
      @job_requests = available_job_requests

      @job_requests = case @filter
      when "urgent"
        @job_requests.where(urgency: [ :urgent, :emergency ])
      when "today"
        @job_requests.where(requested_date: Date.current)
      when "this_week"
        @job_requests.where(requested_date: Date.current..Date.current.end_of_week)
      else
        @job_requests
      end

      @job_requests = @job_requests.order(urgency: :desc, requested_date: :asc)
      render Views::Provider::AvailableJobs::Index.new(
        job_requests: @job_requests,
        filter: @filter
      ), layout: phlex_layout
    end

    def show
      @job_request = available_job_requests.find(params[:id])
      @my_bid = @job_request.job_bids.find_by(provider: Current.user)
      @page_title = @job_request.service_type.name
      render Views::Provider::AvailableJobs::Show.new(
        job_request: @job_request,
        my_bid: @my_bid
      ), layout: phlex_layout
    end

    private

    def available_job_requests
      profile = Current.user.provider_profile
      service_type_ids = profile.provider_services.pluck(:service_type_id)

      # Simplified query without within_radius for now
      JobRequest
        .where(status: :open_for_bids)
        .where(service_type_id: service_type_ids)
        .includes(:property, :service_type, :consumer)
    end
  end
end

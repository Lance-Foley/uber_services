# frozen_string_literal: true

module Provider
  class MyJobsController < BaseController
    before_action :set_job_request, only: [ :show, :start, :complete ]

    def index
      @page_title = "My Jobs"
      @filter = params[:filter] || "active"
      @job_requests = Current.user.provider_job_requests
                             .includes(:property, :service_type, :consumer)

      @job_requests = case @filter
      when "active"
        @job_requests.where(status: %w[accepted payment_authorized in_progress])
      when "pending"
        @job_requests.where(status: %w[accepted payment_authorized])
      when "completed"
        @job_requests.where(status: %w[completed payment_released])
      when "all"
        @job_requests
      else
        @job_requests.where(status: %w[accepted payment_authorized in_progress])
      end

      @job_requests = @job_requests.order(requested_date: :asc)
      render Views::Provider::MyJobs::Index.new(
        job_requests: @job_requests,
        filter: @filter
      ), layout: phlex_layout
    end

    def show
      @consumer = @job_request.consumer
      @review = @job_request.reviews.find_by(reviewer: Current.user)
      @page_title = @job_request.service_type.name
      render Views::Provider::MyJobs::Show.new(
        job_request: @job_request,
        consumer: @consumer,
        review: @review
      ), layout: phlex_layout
    end

    def start
      unless @job_request.payment_authorized?
        redirect_to provider_my_job_path(@job_request), alert: "Cannot start job - payment not authorized."
        return
      end

      if @job_request.start!
        redirect_to provider_my_job_path(@job_request), notice: "Job started!"
      else
        redirect_to provider_my_job_path(@job_request), alert: "Could not start job."
      end
    end

    def complete
      unless @job_request.in_progress?
        redirect_to provider_my_job_path(@job_request), alert: "Cannot complete job - not in progress."
        return
      end

      if @job_request.complete!
        redirect_to provider_my_job_path(@job_request), notice: "Job completed! Payment will be released after 24 hours."
      else
        redirect_to provider_my_job_path(@job_request), alert: "Could not complete job."
      end
    end

    private

    def set_job_request
      @job_request = Current.user.provider_job_requests.find(params[:id])
    end
  end
end

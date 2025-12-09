# frozen_string_literal: true

module Admin
  class JobRequestsController < BaseController
    before_action :set_job_request, only: [ :show ]

    def index
      @job_requests = JobRequest.includes(:consumer, :provider, :service_type, :property)
                                .order(created_at: :desc)
      @job_requests = @job_requests.where(status: params[:status]) if params[:status].present?
    end

    def show
    end

    private

    def set_job_request
      @job_request = JobRequest.includes(:consumer, :provider, :service_type, :payments, :reviews)
                               .find(params[:id])
    end
  end
end

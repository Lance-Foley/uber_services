# frozen_string_literal: true

module Provider
  class BidsController < BaseController
    before_action :set_job_request

    def new
      if @job_request.job_bids.exists?(provider: Current.user)
        redirect_to provider_available_job_path(@job_request), alert: "You have already submitted a bid."
        return
      end

      @bid = @job_request.job_bids.build(provider: Current.user)
      @provider_service = Current.user.provider_profile.provider_services
                                 .find_by(service_type_id: @job_request.service_type_id)
      @page_title = "Submit Bid"
      render Views::Provider::Bids::New.new(
        job_request: @job_request,
        bid: @bid,
        provider_service: @provider_service
      ), layout: phlex_layout
    end

    def create
      @bid = @job_request.job_bids.build(bid_params)
      @bid.provider = Current.user

      if @bid.save
        redirect_to provider_available_job_path(@job_request), notice: "Bid submitted successfully!"
      else
        @provider_service = Current.user.provider_profile.provider_services
                                   .find_by(service_type_id: @job_request.service_type_id)
        @page_title = "Submit Bid"
        render Views::Provider::Bids::New.new(
          job_request: @job_request,
          bid: @bid,
          provider_service: @provider_service
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    def destroy
      @bid = @job_request.job_bids.find_by!(provider: Current.user)

      if @bid.pending?
        @bid.destroy
        redirect_to provider_available_jobs_path, notice: "Bid withdrawn."
      else
        redirect_to provider_available_job_path(@job_request), alert: "Cannot withdraw bid in current state."
      end
    end

    private

    def set_job_request
      @job_request = JobRequest.where(status: :open_for_bids).find(params[:available_job_id])
    end

    def bid_params
      params.require(:job_bid).permit(:bid_amount, :estimated_arrival, :estimated_duration_minutes, :message)
    end
  end
end

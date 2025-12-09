# frozen_string_literal: true

module JobRequests
  class BidsController < ApplicationController
    before_action :set_job_request
    before_action :set_bid, only: [ :show, :accept, :reject ]

    def index
      @page_title = "Bids"
      @bids = @job_request.job_bids
                          .includes(provider: :provider_profile)
                          .order(created_at: :desc)
      render Views::JobRequests::Bids::Index.new(
        job_request: @job_request,
        bids: @bids
      ), layout: phlex_layout
    end

    def show
      @provider = @bid.provider
      @provider_profile = @provider.provider_profile
      @page_title = @provider_profile&.business_name || @provider.display_name
      render Views::JobRequests::Bids::Show.new(
        job_request: @job_request,
        bid: @bid,
        provider: @provider,
        provider_profile: @provider_profile
      ), layout: phlex_layout
    end

    def accept
      unless @job_request.open_for_bids?
        redirect_to job_request_path(@job_request), alert: "Cannot accept bids for this job request."
        return
      end

      ActiveRecord::Base.transaction do
        # Accept this bid
        @bid.update!(status: :accepted)

        # Reject all other bids
        @job_request.job_bids.where.not(id: @bid.id).update_all(status: :rejected)

        # Update job request
        @job_request.update!(
          provider: @bid.provider,
          final_price: @bid.bid_amount,
          provider_payout: @bid.bid_amount * 0.85,
          platform_fee: @bid.bid_amount * 0.15
        )

        # Transition state
        @job_request.accept!
      end

      redirect_to job_request_path(@job_request), notice: "Bid accepted! Payment authorization required."
    rescue => e
      redirect_to job_request_path(@job_request), alert: "Could not accept bid: #{e.message}"
    end

    def reject
      @bid.update!(status: :rejected)
      redirect_to job_request_bids_path(@job_request), notice: "Bid rejected."
    end

    private

    def set_job_request
      @job_request = Current.user.consumer_job_requests.find(params[:job_request_id])
    end

    def set_bid
      @bid = @job_request.job_bids.find(params[:id])
    end
  end
end

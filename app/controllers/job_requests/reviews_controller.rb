# frozen_string_literal: true

module JobRequests
  class ReviewsController < ApplicationController
    before_action :set_job_request

    def new
      unless @job_request.completed? || @job_request.payment_released?
        redirect_to job_request_path(@job_request), alert: "Cannot review until job is completed."
        return
      end

      if @job_request.reviews.exists?(reviewer: Current.user)
        redirect_to job_request_path(@job_request), alert: "You have already reviewed this job."
        return
      end

      @review = @job_request.reviews.build(
        reviewer: Current.user,
        reviewee: @job_request.provider
      )
      @page_title = "Leave a Review"
      render Views::Reviews::New.new(
        review: @review,
        job_request: @job_request,
        reviewee: @job_request.provider
      ), layout: phlex_layout
    end

    def create
      @review = @job_request.reviews.build(review_params)
      @review.reviewer = Current.user
      @review.reviewee = @job_request.provider

      if @review.save
        redirect_to job_request_path(@job_request), notice: "Thank you for your review!"
      else
        @page_title = "Leave a Review"
        render Views::Reviews::New.new(
          review: @review,
          job_request: @job_request,
          reviewee: @job_request.provider
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    private

    def set_job_request
      @job_request = Current.user.consumer_job_requests.find(params[:job_request_id])
    end

    def review_params
      params.require(:review).permit(:rating, :comment)
    end
  end
end

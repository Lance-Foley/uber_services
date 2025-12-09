# frozen_string_literal: true

module Provider
  class ReviewsController < BaseController
    before_action :set_job_request

    def new
      unless @job_request.completed? || @job_request.payment_released?
        redirect_to provider_my_job_path(@job_request), alert: "Cannot review until job is completed."
        return
      end

      if @job_request.reviews.exists?(reviewer: Current.user)
        redirect_to provider_my_job_path(@job_request), alert: "You have already reviewed this job."
        return
      end

      @review = @job_request.reviews.build(
        reviewer: Current.user,
        reviewee: @job_request.consumer
      )
      @page_title = "Leave a Review"
      render Views::Reviews::New.new(
        review: @review,
        job_request: @job_request,
        reviewee: @job_request.consumer,
        is_provider_context: true
      ), layout: phlex_layout
    end

    def create
      @review = @job_request.reviews.build(review_params)
      @review.reviewer = Current.user
      @review.reviewee = @job_request.consumer

      if @review.save
        redirect_to provider_my_job_path(@job_request), notice: "Thank you for your review!"
      else
        @page_title = "Leave a Review"
        render Views::Reviews::New.new(
          review: @review,
          job_request: @job_request,
          reviewee: @job_request.consumer,
          is_provider_context: true
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    private

    def set_job_request
      @job_request = Current.user.provider_job_requests.find(params[:my_job_id])
    end

    def review_params
      params.require(:review).permit(:rating, :comment)
    end
  end
end

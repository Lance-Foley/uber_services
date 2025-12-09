# frozen_string_literal: true

class JobRequestsController < ApplicationController
  before_action :set_job_request, only: [ :show, :edit, :update, :destroy ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @page_title = "My Jobs"
    @filter = params[:filter] || "all"
    @job_requests = Current.user.consumer_job_requests
                           .includes(:service_type, :property, :provider)
                           .order(created_at: :desc)

    @job_requests = case @filter
    when "active"
      @job_requests.where(status: %w[open_for_bids accepted payment_authorized in_progress])
    when "pending"
      @job_requests.where(status: %w[pending open_for_bids])
    when "completed"
      @job_requests.where(status: %w[completed payment_released])
    else
      @job_requests
    end

    render Views::JobRequests::Index.new(job_requests: @job_requests, filter: @filter), layout: phlex_layout
  end

  def show
    @page_title = @job_request.service_type&.name || "Job Request"
    @bids = @job_request.job_bids.includes(provider: :provider_profile).order(created_at: :desc)
    render Views::JobRequests::Show.new(job_request: @job_request, bids: @bids, current_user: Current.user), layout: phlex_layout
  end

  def new
    @page_title = "New Request"
    @job_request = Current.user.consumer_job_requests.build
    render Views::JobRequests::New.new(
      job_request: @job_request,
      properties: @properties,
      service_categories: @service_categories
    ), layout: phlex_layout
  end

  def create
    @job_request = Current.user.consumer_job_requests.build(job_request_params)

    if @job_request.save
      @job_request.open_bidding! if @job_request.may_open_bidding?
      redirect_to job_request_path(@job_request), notice: "Job request created successfully."
    else
      @page_title = "New Request"
      render Views::JobRequests::New.new(
        job_request: @job_request,
        properties: @properties,
        service_categories: @service_categories
      ), layout: phlex_layout, status: :unprocessable_entity
    end
  end

  def edit
    unless @job_request.pending? || @job_request.open_for_bids?
      redirect_to job_request_path(@job_request), alert: "Cannot edit job request in current state."
      return
    end
    @page_title = "Edit Request"
    render Views::JobRequests::Edit.new(
      job_request: @job_request,
      properties: @properties,
      service_categories: @service_categories
    ), layout: phlex_layout
  end

  def update
    unless @job_request.pending? || @job_request.open_for_bids?
      redirect_to job_request_path(@job_request), alert: "Cannot edit job request in current state."
      return
    end

    if @job_request.update(job_request_params)
      redirect_to job_request_path(@job_request), notice: "Job request updated successfully."
    else
      @page_title = "Edit Request"
      render Views::JobRequests::Edit.new(
        job_request: @job_request,
        properties: @properties,
        service_categories: @service_categories
      ), layout: phlex_layout, status: :unprocessable_entity
    end
  end

  def destroy
    if @job_request.may_cancel?
      @job_request.cancel!(
        cancelled_by: Current.user,
        cancellation_reason: "Cancelled by consumer"
      )
      redirect_to job_requests_path, notice: "Job request cancelled."
    else
      redirect_to job_request_path(@job_request), alert: "Cannot cancel job request in current state."
    end
  end

  private

  def set_job_request
    @job_request = Current.user.consumer_job_requests.find(params[:id])
  end

  def set_form_data
    @properties = Current.user.properties.where(active: true).order(primary: :desc, name: :asc)
    @service_categories = ServiceCategory.where(active: true).includes(:service_types).order(:position)
  end

  def job_request_params
    params.require(:job_request).permit(
      :property_id, :service_type_id, :title, :description,
      :requested_date, :requested_time_start, :requested_time_end,
      :urgency, :flexible_timing
    )
  end
end

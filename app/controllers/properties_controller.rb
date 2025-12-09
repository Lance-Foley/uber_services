# frozen_string_literal: true

class PropertiesController < ApplicationController
  before_action :set_property, only: [ :show, :edit, :update, :destroy, :set_primary ]

  def index
    @page_title = "My Properties"
    @properties = Current.user.properties.order(primary: :desc, created_at: :desc)
    render Views::Properties::Index.new(properties: @properties), layout: phlex_layout
  end

  def show
    @page_title = @property.name || "Property"
    render Views::Properties::Show.new(property: @property), layout: phlex_layout
  end

  def new
    @page_title = "Add Property"
    @property = Current.user.properties.build
    render Views::Properties::New.new(property: @property), layout: phlex_layout
  end

  def create
    @property = Current.user.properties.build(property_params)

    if @property.save
      redirect_to properties_path, notice: "Property added successfully."
    else
      @page_title = "Add Property"
      render Views::Properties::New.new(property: @property), layout: phlex_layout, status: :unprocessable_entity
    end
  end

  def edit
    @page_title = "Edit Property"
    render Views::Properties::Edit.new(property: @property), layout: phlex_layout
  end

  def update
    if @property.update(property_params)
      redirect_to properties_path, notice: "Property updated successfully."
    else
      @page_title = "Edit Property"
      render Views::Properties::Edit.new(property: @property), layout: phlex_layout, status: :unprocessable_entity
    end
  end

  def destroy
    if @property.job_requests.where.not(status: [ "completed", "cancelled", "payment_released" ]).exists?
      redirect_to properties_path, alert: "Cannot delete property with active job requests."
    else
      @property.destroy
      redirect_to properties_path, notice: "Property removed successfully."
    end
  end

  def set_primary
    # Remove primary from all other properties
    Current.user.properties.update_all(primary: false)
    @property.update(primary: true)

    redirect_to properties_path, notice: "Primary property updated."
  end

  private

  def set_property
    @property = Current.user.properties.find(params[:id])
  end

  def property_params
    params.require(:property).permit(
      :name, :address_line_1, :address_line_2, :city, :state, :zip_code,
      :property_size, :special_instructions, :driveway_length_ft, :lot_size_sqft
    )
  end
end

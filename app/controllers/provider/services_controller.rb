# frozen_string_literal: true

module Provider
  class ServicesController < BaseController
    before_action :set_provider_service, only: [ :show, :edit, :update, :destroy ]
    before_action :set_form_data, only: [ :new, :create, :edit, :update ]

    def index
      @page_title = "My Services"
      @services = Current.user.provider_profile.provider_services
                         .includes(:service_type)
                         .order(:created_at)
      render Views::Provider::Services::Index.new(services: @services), layout: phlex_layout
    end

    def show
      redirect_to provider_services_path
    end

    def new
      @page_title = "Add Service"
      @provider_service = Current.user.provider_profile.provider_services.build
      render Views::Provider::Services::New.new(
        provider_service: @provider_service,
        service_categories: @service_categories
      ), layout: phlex_layout
    end

    def create
      @provider_service = Current.user.provider_profile.provider_services.build(service_params)

      if @provider_service.save
        redirect_to provider_services_path, notice: "Service added successfully."
      else
        @page_title = "Add Service"
        render Views::Provider::Services::New.new(
          provider_service: @provider_service,
          service_categories: @service_categories
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    def edit
      @page_title = "Edit Service"
      render Views::Provider::Services::Edit.new(
        provider_service: @provider_service,
        service_categories: @service_categories
      ), layout: phlex_layout
    end

    def update
      if @provider_service.update(service_params)
        redirect_to provider_services_path, notice: "Service updated successfully."
      else
        @page_title = "Edit Service"
        render Views::Provider::Services::Edit.new(
          provider_service: @provider_service,
          service_categories: @service_categories
        ), layout: phlex_layout, status: :unprocessable_entity
      end
    end

    def destroy
      @provider_service.destroy
      redirect_to provider_services_path, notice: "Service removed."
    end

    private

    def set_provider_service
      @provider_service = Current.user.provider_profile.provider_services.find(params[:id])
    end

    def set_form_data
      @service_categories = ServiceCategory.where(active: true).includes(:service_types).order(:position)
    end

    def service_params
      params.require(:provider_service).permit(
        :service_type_id, :pricing_model, :base_price, :hourly_rate,
        :min_charge, :notes, :active, size_pricing: {}
      )
    end
  end
end

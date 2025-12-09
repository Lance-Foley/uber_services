# frozen_string_literal: true

module Admin
  class PaymentsController < BaseController
    before_action :set_payment, only: [ :show ]

    def index
      @payments = Payment.includes(:payer, :payee, :job_request)
                         .order(created_at: :desc)
      @payments = @payments.where(status: params[:status]) if params[:status].present?
    end

    def show
    end

    private

    def set_payment
      @payment = Payment.includes(:payer, :payee, :job_request).find(params[:id])
    end
  end
end

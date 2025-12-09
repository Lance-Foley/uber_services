# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_users: User.count,
        active_users: User.active.count,
        admin_users: User.admin.count,
        total_providers: User.providers.count,
        total_job_requests: JobRequest.count,
        pending_jobs: JobRequest.where(status: "pending").count,
        in_progress_jobs: JobRequest.where(status: "in_progress").count,
        completed_jobs: JobRequest.where(status: "completed").count,
        total_payments: Payment.count,
        captured_payments: Payment.captured.count,
        total_revenue: Payment.captured.sum(:platform_fee)
      }
    end
  end
end

# frozen_string_literal: true

module Components
  module JobRequests
    class JobStatusBadge < Components::Base
    def initialize(status:)
      @status = status.to_s
    end

    def view_template
      Badge(variant: badge_variant, class: "capitalize") do
        status_label
      end
    end

    private

    def badge_variant
      case @status
      when "pending" then nil
      when "open_for_bids" then :secondary
      when "accepted", "payment_authorized" then :outline
      when "in_progress" then :secondary
      when "completed", "payment_released" then :success
      when "cancelled" then :destructive
      when "disputed" then :warning
      else nil
      end
    end

    def status_label
      case @status
      when "pending" then "Pending"
      when "open_for_bids" then "Open for Bids"
      when "accepted" then "Accepted"
      when "payment_authorized" then "Payment Authorized"
      when "in_progress" then "In Progress"
      when "completed" then "Completed"
      when "payment_released" then "Paid"
      when "cancelled" then "Cancelled"
      when "disputed" then "Disputed"
      else @status.humanize
      end
    end
    end
  end
end

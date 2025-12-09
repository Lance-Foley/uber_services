# frozen_string_literal: true

module Components
  module JobRequests
    class UrgencyBadge < Components::Base
    def initialize(urgency:)
      @urgency = urgency.to_s
    end

    def view_template
      Badge(variant: badge_variant) do
        urgency_label
      end
    end

    private

    def badge_variant
      case @urgency
      when "normal" then nil
      when "urgent" then :warning
      when "emergency" then :destructive
      else nil
      end
    end

    def urgency_label
      case @urgency
      when "normal" then "Normal"
      when "urgent" then "Urgent"
      when "emergency" then "Emergency"
      else @urgency.humanize
      end
    end
    end
  end
end

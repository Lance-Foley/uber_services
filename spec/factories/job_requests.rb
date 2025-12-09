FactoryBot.define do
  factory :job_request do
    consumer { nil }
    provider { nil }
    property { nil }
    service_type { nil }
    title { "MyString" }
    description { "MyText" }
    requested_date { "2025-12-09 14:10:49" }
    requested_time_start { "2025-12-09 14:10:49" }
    requested_time_end { "2025-12-09 14:10:49" }
    flexible_timing { false }
    urgency { 1 }
    status { "MyString" }
    estimated_price { "9.99" }
    final_price { "9.99" }
    platform_fee { "9.99" }
    provider_payout { "9.99" }
    platform_fee_percentage { "9.99" }
    accepted_at { "2025-12-09 14:10:49" }
    started_at { "2025-12-09 14:10:49" }
    completed_at { "2025-12-09 14:10:49" }
    cancelled_at { "2025-12-09 14:10:49" }
    cancellation_reason { "MyString" }
    cancelled_by { nil }
    metadata { "" }
  end
end

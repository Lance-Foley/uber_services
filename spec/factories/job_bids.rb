FactoryBot.define do
  factory :job_bid do
    job_request { nil }
    provider { nil }
    bid_amount { "9.99" }
    message { "MyText" }
    estimated_arrival { "2025-12-09 14:10:50" }
    estimated_duration_minutes { 1 }
    status { "MyString" }
  end
end

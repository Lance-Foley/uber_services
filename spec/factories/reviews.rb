FactoryBot.define do
  factory :review do
    job_request { nil }
    reviewer { nil }
    reviewee { nil }
    rating { 1 }
    comment { "MyText" }
    response { "MyText" }
    responded_at { "2025-12-09 14:10:59" }
    visible { false }
    flagged { false }
  end
end

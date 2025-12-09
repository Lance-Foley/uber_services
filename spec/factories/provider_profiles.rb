FactoryBot.define do
  factory :provider_profile do
    user { nil }
    business_name { "MyString" }
    bio { "MyText" }
    service_radius_miles { 1 }
    average_rating { "9.99" }
    total_reviews { 1 }
    completed_jobs { 1 }
    verified { false }
    accepting_jobs { false }
    availability_schedule { "" }
    stripe_account_id { "MyString" }
    stripe_account_status { "MyString" }
    stripe_charges_enabled { false }
    stripe_payouts_enabled { false }
  end
end

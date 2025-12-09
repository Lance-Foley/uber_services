FactoryBot.define do
  factory :provider_service do
    provider_profile { nil }
    service_type { nil }
    pricing_model { 1 }
    base_price { "9.99" }
    hourly_rate { "9.99" }
    min_charge { "9.99" }
    size_pricing { "" }
    notes { "MyText" }
    active { false }
  end
end

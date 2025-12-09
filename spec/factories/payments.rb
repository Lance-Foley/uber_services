FactoryBot.define do
  factory :payment do
    job_request { nil }
    payer { nil }
    payee { nil }
    stripe_payment_intent_id { "MyString" }
    stripe_charge_id { "MyString" }
    stripe_transfer_id { "MyString" }
    amount { "9.99" }
    platform_fee { "9.99" }
    provider_amount { "9.99" }
    currency { "MyString" }
    status { "MyString" }
    authorized_at { "2025-12-09 14:10:58" }
    captured_at { "2025-12-09 14:10:58" }
    released_at { "2025-12-09 14:10:58" }
    refunded_at { "2025-12-09 14:10:58" }
    failure_reason { "MyText" }
    metadata { "" }
  end
end

FactoryBot.define do
  factory :message do
    conversation { nil }
    sender { nil }
    content { "MyText" }
    read { false }
    read_at { "2025-12-09 14:11:08" }
  end
end

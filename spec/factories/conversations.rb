FactoryBot.define do
  factory :conversation do
    job_request { nil }
    participant_one { nil }
    participant_two { nil }
    last_message_at { "2025-12-09 14:11:00" }
    active { false }
  end
end

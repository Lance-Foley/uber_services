FactoryBot.define do
  factory :notification do
    user { nil }
    notification_type { "MyString" }
    title { "MyString" }
    body { "MyText" }
    action_url { "MyString" }
    data { "" }
    read { false }
    read_at { "2025-12-09 14:11:09" }
    push_sent { false }
    push_sent_at { "2025-12-09 14:11:09" }
  end
end

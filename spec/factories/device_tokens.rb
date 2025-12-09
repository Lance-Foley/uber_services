FactoryBot.define do
  factory :device_token do
    user { nil }
    token { "MyString" }
    platform { "MyString" }
    device_id { "MyString" }
    active { false }
  end
end

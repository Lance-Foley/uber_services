FactoryBot.define do
  factory :connected_service do
    user { nil }
    provider { "MyString" }
    uid { "MyString" }
  end
end

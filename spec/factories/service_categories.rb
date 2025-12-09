FactoryBot.define do
  factory :service_category do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    icon_name { "MyString" }
    active { false }
    position { 1 }
  end
end

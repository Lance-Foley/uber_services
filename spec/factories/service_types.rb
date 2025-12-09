FactoryBot.define do
  factory :service_type do
    service_category { nil }
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    icon_name { "MyString" }
    active { false }
    position { 1 }
    suggested_min_price { "9.99" }
    suggested_max_price { "9.99" }
  end
end

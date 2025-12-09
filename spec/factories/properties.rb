FactoryBot.define do
  factory :property do
    user { nil }
    name { "MyString" }
    address_line_1 { "MyString" }
    address_line_2 { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip_code { "MyString" }
    country { "MyString" }
    latitude { "9.99" }
    longitude { "9.99" }
    property_size { 1 }
    lot_size_sqft { "9.99" }
    driveway_length_ft { "9.99" }
    special_instructions { "MyText" }
    photos { "" }
    primary { false }
    active { false }
  end
end

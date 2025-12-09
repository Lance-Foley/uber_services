# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding service categories and types..."

# ======================
# SERVICE CATEGORIES
# ======================

snow_removal = ServiceCategory.find_or_create_by!(slug: "snow-removal") do |category|
  category.name = "Snow Removal"
  category.icon_name = "snowflake"
  category.position = 1
end

lawn_care = ServiceCategory.find_or_create_by!(slug: "lawn-care") do |category|
  category.name = "Lawn Care"
  category.icon_name = "leaf"
  category.position = 2
end

puts "  Created #{ServiceCategory.count} service categories"

# ======================
# SERVICE TYPES - Snow Removal
# ======================

ServiceType.find_or_create_by!(slug: "driveway-plowing") do |service_type|
  service_type.service_category = snow_removal
  service_type.name = "Driveway Plowing"
  service_type.description = "Clear snow from your driveway using a plow truck"
  service_type.suggested_min_price = 35.00
  service_type.suggested_max_price = 100.00
  service_type.position = 1
end

ServiceType.find_or_create_by!(slug: "sidewalk-shoveling") do |service_type|
  service_type.service_category = snow_removal
  service_type.name = "Sidewalk Shoveling"
  service_type.description = "Hand shovel sidewalks, walkways, and steps"
  service_type.suggested_min_price = 25.00
  service_type.suggested_max_price = 60.00
  service_type.position = 2
end

ServiceType.find_or_create_by!(slug: "snow-blowing") do |service_type|
  service_type.service_category = snow_removal
  service_type.name = "Snow Blowing"
  service_type.description = "Clear snow using a snow blower for driveways and walkways"
  service_type.suggested_min_price = 40.00
  service_type.suggested_max_price = 80.00
  service_type.position = 3
end

ServiceType.find_or_create_by!(slug: "roof-snow-clearing") do |service_type|
  service_type.service_category = snow_removal
  service_type.name = "Roof Snow Clearing"
  service_type.description = "Safely remove heavy snow from your roof to prevent damage"
  service_type.suggested_min_price = 150.00
  service_type.suggested_max_price = 400.00
  service_type.position = 4
end

ServiceType.find_or_create_by!(slug: "ice-treatment") do |service_type|
  service_type.service_category = snow_removal
  service_type.name = "De-Icing / Salt Treatment"
  service_type.description = "Apply salt or de-icer to prevent ice buildup"
  service_type.suggested_min_price = 20.00
  service_type.suggested_max_price = 50.00
  service_type.position = 5
end

# ======================
# SERVICE TYPES - Lawn Care
# ======================

ServiceType.find_or_create_by!(slug: "lawn-mowing") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Lawn Mowing"
  service_type.description = "Regular lawn mowing with edging and trimming"
  service_type.suggested_min_price = 30.00
  service_type.suggested_max_price = 80.00
  service_type.position = 1
end

ServiceType.find_or_create_by!(slug: "leaf-raking") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Leaf Raking"
  service_type.description = "Rake and bag fallen leaves from your yard"
  service_type.suggested_min_price = 40.00
  service_type.suggested_max_price = 120.00
  service_type.position = 2
end

ServiceType.find_or_create_by!(slug: "leaf-blowing") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Leaf Blowing"
  service_type.description = "Blow leaves into piles for easy collection"
  service_type.suggested_min_price = 35.00
  service_type.suggested_max_price = 90.00
  service_type.position = 3
end

ServiceType.find_or_create_by!(slug: "hedge-trimming") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Hedge Trimming"
  service_type.description = "Trim and shape hedges and shrubs"
  service_type.suggested_min_price = 50.00
  service_type.suggested_max_price = 150.00
  service_type.position = 4
end

ServiceType.find_or_create_by!(slug: "tree-planting") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Tree Planting"
  service_type.description = "Plant trees with proper soil preparation"
  service_type.suggested_min_price = 75.00
  service_type.suggested_max_price = 200.00
  service_type.position = 5
end

ServiceType.find_or_create_by!(slug: "garden-weeding") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Garden Weeding"
  service_type.description = "Remove weeds from flower beds and gardens"
  service_type.suggested_min_price = 35.00
  service_type.suggested_max_price = 100.00
  service_type.position = 6
end

ServiceType.find_or_create_by!(slug: "mulching") do |service_type|
  service_type.service_category = lawn_care
  service_type.name = "Mulching"
  service_type.description = "Spread mulch in garden beds and around trees"
  service_type.suggested_min_price = 60.00
  service_type.suggested_max_price = 180.00
  service_type.position = 7
end

puts "  Created #{ServiceType.count} service types"

# ======================
# DEVELOPMENT SEED DATA
# ======================

if Rails.env.development?
  puts "\nSeeding development data..."

  # Create admin user
  admin = User.find_or_create_by!(email_address: "lance.foley@hey.com") do |user|
    user.first_name = "Lance"
    user.last_name = "Foley"
    user.password = "123456"
    user.admin = true
  end
  admin.update!(admin: true) unless admin.admin?
  puts "  Created admin user: #{admin.email_address}"

  # Create test users
  consumer = User.find_or_create_by!(email_address: "consumer@example.com") do |user|
    user.first_name = "John"
    user.last_name = "Consumer"
    user.password = "password123"
    user.phone_number = "5551234567"
  end
  puts "  Created consumer: #{consumer.email_address}"

  provider_user = User.find_or_create_by!(email_address: "provider@example.com") do |user|
    user.first_name = "Jane"
    user.last_name = "Provider"
    user.password = "password123"
    user.phone_number = "5559876543"
  end
  puts "  Created provider user: #{provider_user.email_address}"

  # Create provider profile
  provider_profile = ProviderProfile.find_or_create_by!(user: provider_user) do |profile|
    profile.business_name = "Jane's Home Services"
    profile.bio = "Professional snow removal and lawn care services with 5+ years of experience."
    profile.service_radius_miles = 25
    profile.verified = true
    profile.accepting_jobs = true
  end
  puts "  Created provider profile: #{provider_profile.business_name}"

  # Add provider services
  driveway_plowing = ServiceType.find_by(slug: "driveway-plowing")
  lawn_mowing = ServiceType.find_by(slug: "lawn-mowing")

  if driveway_plowing
    ProviderService.find_or_create_by!(provider_profile: provider_profile, service_type: driveway_plowing) do |ps|
      ps.pricing_model = :per_job
      ps.base_price = 50.00
      ps.active = true
    end
  end

  if lawn_mowing
    ProviderService.find_or_create_by!(provider_profile: provider_profile, service_type: lawn_mowing) do |ps|
      ps.pricing_model = :property_size
      ps.base_price = 40.00
      ps.size_pricing = {
        "small" => 40.00,
        "medium" => 55.00,
        "large" => 75.00,
        "xlarge" => 100.00
      }
      ps.active = true
    end
  end

  puts "  Created #{ProviderService.count} provider services"

  # Create a sample property for the consumer
  property = Property.find_or_create_by!(user: consumer, name: "Home") do |p|
    p.address_line_1 = "123 Main Street"
    p.city = "Boston"
    p.state = "MA"
    p.zip_code = "02101"
    p.property_size = :medium
    p.lot_size_sqft = 5000
    p.driveway_length_ft = 30
    p.primary = true
  end
  puts "  Created property: #{property.name} at #{property.address_line_1}"

  puts "\nDevelopment seed data complete!"
end

puts "\nSeeding complete!"

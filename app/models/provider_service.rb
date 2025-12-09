class ProviderService < ApplicationRecord
  belongs_to :provider_profile
  belongs_to :service_type

  # Enums
  enum :pricing_model, { hourly: 0, per_job: 1, property_size: 2 }

  # Validations
  validates :pricing_model, presence: true
  validates :service_type_id, presence: true
  validates :provider_profile_id, uniqueness: { scope: :service_type_id }

  # Conditional validations based on pricing model
  validates :base_price, presence: true, numericality: { greater_than: 0 }, if: -> { per_job? || property_size? }
  validates :hourly_rate, presence: true, numericality: { greater_than: 0 }, if: -> { hourly? }
  validates :min_charge, numericality: { greater_than: 0 }, allow_nil: true

  # Defaults
  attribute :active, default: true
  attribute :size_pricing, default: {}

  # Scopes
  scope :active, -> { where(active: true) }

  # Instance methods
  def calculate_price(property:, estimated_hours: nil)
    case pricing_model
    when "hourly"
      calculate_hourly_price(estimated_hours)
    when "per_job"
      base_price
    when "property_size"
      calculate_size_based_price(property)
    end
  end

  private

  def calculate_hourly_price(hours)
    return min_charge unless hours
    [ hourly_rate * hours, min_charge ].compact.max
  end

  def calculate_size_based_price(property)
    return base_price unless property&.property_size

    size_key = property.property_size.to_s
    size_pricing[size_key]&.to_d || base_price
  end
end

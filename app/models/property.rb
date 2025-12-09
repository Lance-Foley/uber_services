class Property < ApplicationRecord
  belongs_to :user

  # Associations
  has_many :job_requests, dependent: :restrict_with_error

  # Enums
  enum :property_size, { small: 0, medium: 1, large: 2, xlarge: 3 }

  # Validations
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true

  # Defaults
  attribute :country, default: "US"
  attribute :primary, default: false
  attribute :active, default: true
  attribute :photos, default: []

  # Scopes
  scope :active, -> { where(active: true) }
  scope :primary, -> { where(primary: true) }

  # Geocoding
  geocoded_by :full_address
  after_validation :safe_geocode, if: :address_changed?

  # Callbacks
  before_save :ensure_single_primary

  # Instance methods
  def full_address
    [
      address_line_1,
      address_line_2,
      city,
      state,
      zip_code,
      country
    ].compact.reject(&:blank?).join(", ")
  end

  def short_address
    "#{city}, #{state}"
  end

  def display_address
    [address_line_1, city, state].compact.join(", ")
  end

  private

  def safe_geocode
    geocode
  rescue StandardError => e
    Rails.logger.warn "Geocoding failed for Property #{id}: #{e.message}"
    # Don't fail the save if geocoding fails
  end

  def address_changed?
    address_line_1_changed? || city_changed? || state_changed? || zip_code_changed?
  end

  def ensure_single_primary
    if primary? && primary_changed?
      user.properties.where.not(id: id).update_all(primary: false)
    end
  end
end

class User < ApplicationRecord
  has_secure_password

  # Associations - Authentication
  has_many :sessions, dependent: :destroy
  has_many :connected_services, dependent: :destroy

  # Associations - Profiles
  has_one :provider_profile, dependent: :destroy

  # Associations - Properties
  has_many :properties, dependent: :destroy

  # Associations - Job Requests (as consumer)
  has_many :consumer_job_requests, class_name: "JobRequest", foreign_key: :consumer_id, dependent: :destroy
  # Associations - Job Requests (as provider)
  has_many :provider_job_requests, class_name: "JobRequest", foreign_key: :provider_id

  # Associations - Bids
  has_many :job_bids, foreign_key: :provider_id

  # Associations - Payments
  has_many :payments_made, class_name: "Payment", foreign_key: :payer_id
  has_many :payments_received, class_name: "Payment", foreign_key: :payee_id

  # Associations - Reviews
  has_many :reviews_given, class_name: "Review", foreign_key: :reviewer_id
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id

  # Associations - Messaging
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id

  # Associations - Notifications
  has_many :notifications, dependent: :destroy
  has_many :device_tokens, dependent: :destroy

  # Normalizations
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :phone_number, with: ->(p) { p&.gsub(/\D/, "") }

  # Validations
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update

  # Scopes
  scope :active, -> { where(active: true) }
  scope :admin, -> { where(admin: true) }
  scope :providers, -> { joins(:provider_profile).where.not(provider_profiles: { id: nil }) }

  # Geocoding (for providers)
  geocoded_by :geocode_address
  after_validation :geocode, if: :should_geocode?

  # Instance methods
  def full_name
    [ first_name, last_name ].compact.join(" ")
  end

  def display_name
    full_name.presence || email_address.split("@").first
  end

  def provider?
    provider_profile.present?
  end

  def become_provider!
    create_provider_profile! unless provider_profile
  end

  def average_rating
    provider_profile&.average_rating || 0.0
  end

  private

  def geocode_address
    # For geocoding based on user's primary property or entered address
    nil # Override in subclass or use property geocoding
  end

  def should_geocode?
    latitude_changed? || longitude_changed?
  end
end

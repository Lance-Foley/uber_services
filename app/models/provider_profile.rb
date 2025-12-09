class ProviderProfile < ApplicationRecord
  belongs_to :user

  # Associations
  has_many :provider_services, dependent: :destroy
  has_many :service_types, through: :provider_services

  # Validations
  validates :user_id, uniqueness: true
  validates :service_radius_miles, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Defaults
  attribute :service_radius_miles, default: 25
  attribute :average_rating, default: 0.0
  attribute :total_reviews, default: 0
  attribute :completed_jobs, default: 0
  attribute :verified, default: false
  attribute :accepting_jobs, default: true
  attribute :availability_schedule, default: {}
  attribute :stripe_charges_enabled, default: false
  attribute :stripe_payouts_enabled, default: false

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :accepting_jobs, -> { where(accepting_jobs: true) }
  scope :stripe_ready, -> { where(stripe_charges_enabled: true, stripe_payouts_enabled: true) }

  # Callbacks
  after_update :update_user_geocoding, if: :saved_change_to_service_radius_miles?

  # Instance methods
  def update_rating_stats!
    reviews = user.reviews_received
    update!(
      average_rating: reviews.average(:rating)&.round(2) || 0.0,
      total_reviews: reviews.count
    )
  end

  def stripe_onboarded?
    stripe_account_id.present? && stripe_charges_enabled? && stripe_payouts_enabled?
  end

  def can_receive_jobs?
    accepting_jobs? && stripe_onboarded?
  end

  private

  def update_user_geocoding
    # Trigger re-geocoding if needed
  end
end

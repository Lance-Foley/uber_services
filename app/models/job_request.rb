class JobRequest < ApplicationRecord
  include AASM

  # Associations
  belongs_to :consumer, class_name: "User"
  belongs_to :provider, class_name: "User", optional: true
  belongs_to :property
  belongs_to :service_type
  belongs_to :cancelled_by, class_name: "User", optional: true

  has_many :job_bids, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :conversation, dependent: :destroy

  # Enums
  enum :urgency, { normal: 0, urgent: 1, emergency: 2 }

  # Validations
  validates :requested_date, presence: true
  validates :status, presence: true

  # Defaults
  attribute :status, default: "pending"
  attribute :platform_fee_percentage, default: 15.0
  attribute :metadata, default: {}

  # Scopes
  scope :active, -> { where.not(status: %w[cancelled payment_released]) }
  scope :for_date, ->(date) { where(requested_date: date.all_day) }
  scope :pending_payment_release, -> { where(status: "completed").where("completed_at < ?", 24.hours.ago) }

  # AASM State Machine
  aasm column: :status do
    state :pending, initial: true
    state :open_for_bids
    state :accepted
    state :payment_authorized
    state :in_progress
    state :completed
    state :payment_released
    state :cancelled
    state :disputed

    event :open_bidding do
      transitions from: :pending, to: :open_for_bids
    end

    event :accept do
      transitions from: [ :pending, :open_for_bids ], to: :accepted
      after do
        update!(accepted_at: Time.current)
      end
    end

    event :authorize_payment do
      transitions from: :accepted, to: :payment_authorized
    end

    event :start do
      transitions from: :payment_authorized, to: :in_progress
      after do
        update!(started_at: Time.current)
      end
    end

    event :complete do
      transitions from: :in_progress, to: :completed
      after do
        update!(completed_at: Time.current)
      end
    end

    event :release_payment do
      transitions from: :completed, to: :payment_released
    end

    event :cancel do
      transitions from: [ :pending, :open_for_bids, :accepted, :payment_authorized ], to: :cancelled
      after do |user, reason|
        update!(
          cancelled_at: Time.current,
          cancelled_by: user,
          cancellation_reason: reason
        )
      end
    end

    event :dispute do
      transitions from: [ :in_progress, :completed ], to: :disputed
    end
  end

  # Callbacks
  before_save :calculate_fees, if: :final_price_changed?

  # Instance methods
  def calculate_estimated_price(provider_service)
    return unless provider_service

    price = provider_service.calculate_price(property: property)
    urgency_multiplier = urgency_multipliers[urgency] || 1.0

    self.estimated_price = (price * urgency_multiplier).round(2)
  end

  def finalize_price!(amount)
    self.final_price = amount
    calculate_fees
    save!
  end

  def can_be_cancelled?
    %w[pending open_for_bids accepted payment_authorized].include?(status)
  end

  def awaiting_payment_release?
    completed? && completed_at && completed_at < 24.hours.ago
  end

  private

  def calculate_fees
    return unless final_price

    self.platform_fee = (final_price * platform_fee_percentage / 100).round(2)
    self.provider_payout = (final_price - platform_fee).round(2)
  end

  def urgency_multipliers
    {
      "normal" => 1.0,
      "urgent" => 1.25,
      "emergency" => 1.5
    }
  end
end

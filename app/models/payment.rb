class Payment < ApplicationRecord
  belongs_to :job_request
  belongs_to :payer, class_name: "User"
  belongs_to :payee, class_name: "User"

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }

  # Defaults
  attribute :currency, default: "usd"
  attribute :status, default: "pending"
  attribute :metadata, default: {}

  # Scopes
  scope :authorized, -> { where(status: "authorized") }
  scope :captured, -> { where(status: "captured") }
  scope :released, -> { where(status: "released") }
  scope :refunded, -> { where(status: "refunded") }

  # Instance methods
  def authorize!
    update!(status: "authorized", authorized_at: Time.current)
  end

  def capture!
    update!(status: "captured", captured_at: Time.current)
  end

  def release!
    update!(status: "released", released_at: Time.current)
  end

  def refund!
    update!(status: "refunded", refunded_at: Time.current)
  end
end

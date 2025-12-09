class JobBid < ApplicationRecord
  belongs_to :job_request
  belongs_to :provider, class_name: "User"

  # Validations
  validates :bid_amount, presence: true, numericality: { greater_than: 0 }
  validates :provider_id, uniqueness: { scope: :job_request_id }

  # Defaults
  attribute :status, default: "pending"

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }

  # Instance methods
  def accept!
    transaction do
      update!(status: "accepted")
      job_request.job_bids.where.not(id: id).update_all(status: "rejected")
      job_request.update!(provider: provider)
      job_request.accept!
    end
  end

  def reject!
    update!(status: "rejected")
  end

  def withdraw!
    update!(status: "withdrawn")
  end
end

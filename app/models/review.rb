class Review < ApplicationRecord
  belongs_to :job_request
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :reviewer_id, uniqueness: { scope: :job_request_id }

  # Defaults
  attribute :visible, default: true
  attribute :flagged, default: false

  # Scopes
  scope :visible, -> { where(visible: true) }
  scope :flagged, -> { where(flagged: true) }

  # Callbacks
  after_save :update_reviewee_rating_stats

  # Instance methods
  def respond!(response_text)
    update!(response: response_text, responded_at: Time.current)
  end

  private

  def update_reviewee_rating_stats
    reviewee.provider_profile&.update_rating_stats!
  end
end

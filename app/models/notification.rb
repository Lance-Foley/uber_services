class Notification < ApplicationRecord
  belongs_to :user

  # Validations
  validates :notification_type, presence: true
  validates :title, presence: true

  # Defaults
  attribute :read, default: false
  attribute :push_sent, default: false
  attribute :data, default: {}

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :push_pending, -> { where(push_sent: false) }

  # Notification types
  TYPES = %w[
    job_request_created
    job_request_accepted
    job_bid_received
    job_bid_accepted
    job_started
    job_completed
    payment_authorized
    payment_released
    new_message
    new_review
  ].freeze

  validates :notification_type, inclusion: { in: TYPES }

  # Instance methods
  def mark_as_read!
    update!(read: true) unless read?
  end

  def mark_push_sent!
    update!(push_sent: true)
  end

  # Class methods
  def self.create_for_job_event!(user:, job_request:, event:)
    titles = {
      "accepted" => "Job Accepted",
      "started" => "Job Started",
      "completed" => "Job Completed",
      "payment_released" => "Payment Released"
    }

    bodies = {
      "accepted" => "Your job request has been accepted by a provider.",
      "started" => "Your service provider has started the job.",
      "completed" => "Your job has been marked as completed.",
      "payment_released" => "Payment has been released to the provider."
    }

    create!(
      user: user,
      notification_type: "job_#{event}",
      title: titles[event],
      body: bodies[event],
      action_url: "/job_requests/#{job_request.id}",
      data: { job_request_id: job_request.id }
    )
  end
end

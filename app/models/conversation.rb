class Conversation < ApplicationRecord
  belongs_to :job_request, optional: true
  belongs_to :participant_one, class_name: "User"
  belongs_to :participant_two, class_name: "User"

  # Associations
  has_many :messages, dependent: :destroy

  # Defaults
  attribute :active, default: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_user, ->(user) { where("participant_one_id = ? OR participant_two_id = ?", user.id, user.id) }

  # Class methods
  def self.between(user1, user2)
    where(
      "(participant_one_id = ? AND participant_two_id = ?) OR (participant_one_id = ? AND participant_two_id = ?)",
      user1.id, user2.id, user2.id, user1.id
    ).first
  end

  def self.find_or_create_between(user1, user2, job_request: nil)
    between(user1, user2) || create!(
      participant_one: user1,
      participant_two: user2,
      job_request: job_request
    )
  end

  # Instance methods
  def other_participant(user)
    user.id == participant_one_id ? participant_two : participant_one
  end

  def participants
    [ participant_one, participant_two ]
  end

  def update_last_message_at!
    update!(last_message_at: Time.current)
  end
end

class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  # Validations
  validates :content, presence: true

  # Defaults
  attribute :read, default: false

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :update_conversation_timestamp
  after_create_commit :broadcast_message

  # Instance methods
  def mark_as_read!
    update!(read: true, read_at: Time.current) unless read?
  end

  def recipient
    conversation.other_participant(sender)
  end

  private

  def update_conversation_timestamp
    conversation.update_last_message_at!
  end

  def broadcast_message
    # Turbo Stream broadcast will be implemented here
    # broadcast_append_to conversation, target: "messages", partial: "messages/message", locals: { message: self }
  end
end

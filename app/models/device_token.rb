class DeviceToken < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :platform, presence: true

  # Enums
  enum :platform, { ios: 0, android: 1 }

  # Defaults
  attribute :active, default: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ios, -> { where(platform: :ios) }
  scope :android, -> { where(platform: :android) }

  # Instance methods
  def deactivate!
    update!(active: false)
  end

  def reactivate!
    update!(active: true)
  end

  # Class methods
  def self.register!(user:, token:, platform:)
    # Deactivate any existing tokens with the same token value
    where(token: token).where.not(user: user).update_all(active: false)

    # Find or create the token for this user
    device_token = find_or_initialize_by(user: user, token: token)
    device_token.platform = platform
    device_token.active = true
    device_token.save!
    device_token
  end

  def self.cleanup_inactive!
    where(active: false).where("updated_at < ?", 30.days.ago).delete_all
  end
end

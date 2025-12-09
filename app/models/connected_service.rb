class ConnectedService < ApplicationRecord
  belongs_to :user

  # Validations
  validates :provider, presence: true
  validates :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }

  # Scopes
  scope :google, -> { where(provider: "google_oauth2") }
  scope :apple, -> { where(provider: "apple") }

  # Class methods
  def self.find_for_oauth(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end
end

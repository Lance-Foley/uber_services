class ServiceType < ApplicationRecord
  belongs_to :service_category

  # Associations
  has_many :provider_services, dependent: :destroy
  has_many :provider_profiles, through: :provider_services
  has_many :job_requests, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Defaults
  attribute :active, default: true
  attribute :position, default: 0

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  # Instance methods
  def full_name
    "#{service_category.name} - #{name}"
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end

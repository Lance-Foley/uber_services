class ServiceCategory < ApplicationRecord
  # Associations
  has_many :service_types, dependent: :destroy

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

  private

  def generate_slug
    self.slug = name.parameterize
  end
end

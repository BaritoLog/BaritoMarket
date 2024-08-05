class InfrastructureLocation < ApplicationRecord
  has_many :helm_infra

  scope :active, -> { where(is_active: true) }
end

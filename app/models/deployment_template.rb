class DeploymentTemplate < ApplicationRecord
  validates :name, :source, :bootstrappers, presence: true
  validates :name, uniqueness: { message: 'Component Template already exist with this name' }
end

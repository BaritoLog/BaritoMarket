class DeploymentTemplate < ApplicationRecord
  validates :name, :bootstrappers, presence: true
  validates :name, uniqueness: { message: 'DeploymentTemplate already exist with this name' }
end

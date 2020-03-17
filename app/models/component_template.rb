class ComponentTemplate < ApplicationRecord
  validates :name, :source, :bootstrappers, presence: true
  validates :name, uniqueness: { message: 'ComponentTemplate already exist with this name' }
end

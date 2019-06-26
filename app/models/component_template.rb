class ComponentTemplate < ApplicationRecord
  attr_accessor :infrastructure_component
  validates :name, :source, :bootstrappers, presence: true
  validates :name, uniqueness: { message: 'Component Template already exist with this name' }
end

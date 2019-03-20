class ComponentProperty < ApplicationRecord
  attr_accessor :infrastructure_component
  validates :name, :component_attributes, presence: true
  validates :name, uniqueness: { message: 'Component Template already exist with this name' }
end

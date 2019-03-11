class ComponentProperty < ApplicationRecord
  attr_accessor :infrastructure_component
  validates :name, :component_attributes, presence: true

end

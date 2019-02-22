class ComponentProperty < ApplicationRecord
  validates :env, :name, :instances, presence: true

end

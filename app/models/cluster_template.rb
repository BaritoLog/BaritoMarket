class ClusterTemplate < ApplicationRecord
  attr_accessor :infrastructure

  validates :name, :instances, :options, presence: true

  has_many :infrastructures
end




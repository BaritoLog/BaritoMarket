class ClusterTemplate < ApplicationRecord
  attr_accessor :infrastructure

  validates :name, :manifests, :options, presence: true
  validates :name, uniqueness: { message: 'Cluster template already exist with this name' }

  has_many :infrastructures
end

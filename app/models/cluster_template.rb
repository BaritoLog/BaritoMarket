class ClusterTemplate < ApplicationRecord
  attr_accessor :infrastructure

  validates :env, :name, :max_tps, :instances, :kafka_options, presence: true


  has_many :infrastructures
end




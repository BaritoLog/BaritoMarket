class ComponentTemplate < ApplicationRecord
  attr_accessor :infrastructure

  validates :env, :name, :max_tps, :instances, :kafka_options, presence: true

  enum env_prefix: {
    production: 'p', 
    staging: 's', 
    development: 'd', 
    uat: 'u', 
    internal: 'i', 
    integration: 'g', 
    test: 't',
  }
end




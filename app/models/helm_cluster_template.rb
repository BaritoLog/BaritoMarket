class HelmClusterTemplate < ApplicationRecord
  default_scope { order(name: :asc) }
  validates_uniqueness_of :name
  validates_presence_of :max_tps, :name
  validates :values, helm_values: true
end

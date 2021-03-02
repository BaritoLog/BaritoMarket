class HelmClusterTemplate < ApplicationRecord
  validates_uniqueness_of :name
  validates_presence_of :max_tps, :name
  validates :values, helm_values: true
end

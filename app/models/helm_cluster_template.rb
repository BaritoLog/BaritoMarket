class HelmClusterTemplate < ApplicationRecord
  validates_uniqueness_of :name
  validates_presence_of :max_tps, :name
end

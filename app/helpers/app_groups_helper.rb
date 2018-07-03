module AppGroupsHelper
  def max_tps(infrastructure)
    TPS_CONFIG[infrastructure.capacity]['max_tps']
  end
end

Api::AppsController.subscribe(DatadogListener.new)
Api::V2::AppsController.subscribe(DatadogListener.new)
AppsController.subscribe(DatadogListener.new)
AppGroupsController.subscribe(DatadogListener.new)

PrometheusListener.new.tap do |listener|
  Api::AppsController.subscribe(listener)
  Api::V2::AppsController.subscribe(listener)
  AppsController.subscribe(listener)
  AppGroupsController.subscribe(listener)
end

BaritoBlueprint::Provisioner.subscribe(ProvisioningListener.new)
Api::AppsController.subscribe(RedisCacheListener.new)
AppGroupsController.subscribe(RedisCacheListener.new)
AppsController.subscribe(RedisCacheListener.new)
GateClient.subscribe(RedisCacheListener.new)

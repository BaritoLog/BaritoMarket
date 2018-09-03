Api::AppsController.subscribe(Datadog::Listener.new)
AppsController.subscribe(Datadog::Listener.new)
AppGroupsController.subscribe(Datadog::Listener.new)
BaritoBlueprint::Provisioner.subscribe(ProvisioningListener.new)

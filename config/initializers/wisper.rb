Api::AppsController.subscribe(DatadogListener.new)
AppsController.subscribe(DatadogListener.new)
AppGroupsController.subscribe(DatadogListener.new)
BaritoBlueprint::Provisioner.subscribe(ProvisioningListener.new)

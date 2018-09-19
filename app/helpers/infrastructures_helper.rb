module InfrastructuresHelper
  def show_retry_provision_button(infrastructure_component)
    infrastructure_component.allow_provision? and infrastructure_component.provisioning_error?
  end

  def show_provisioning_check_button(infrastructure_component)
    infrastructure_component.allow_provisioning_check?
  end

  def show_retry_bootstrap_button(infrastructure_component)
    infrastructure_component.allow_bootstrap?
  end
end

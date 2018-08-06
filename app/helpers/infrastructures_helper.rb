module InfrastructuresHelper
  def show_retry_bootstrap_button(infrastructure_component)
    infrastructure_component.allow_bootstrap?
  end
end

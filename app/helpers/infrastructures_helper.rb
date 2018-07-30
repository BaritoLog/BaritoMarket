module InfrastructuresHelper
  def show_retry_button(infrastructure_component)
    infrastructure_component.bootstrap_error?
  end
end

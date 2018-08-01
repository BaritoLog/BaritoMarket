module InfrastructuresHelper
  def show_retry_button(infrastructure_component)
    infrastructure_component.any_errors?
  end
end

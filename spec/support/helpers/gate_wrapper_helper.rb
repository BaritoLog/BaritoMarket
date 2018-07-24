module GateWrapperHelper
  def set_check_user_groups(response = {})
    allow_any_instance_of(GateWrapper).to receive(:check_user_groups).and_return(response)
  end
end

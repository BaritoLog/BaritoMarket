module GateClientHelper
  def set_check_user_groups(response = {})
    allow_any_instance_of(GateClient).to(
      receive(:check_user_groups).
      and_return(response)
    )
  end
end

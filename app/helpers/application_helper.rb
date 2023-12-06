module ApplicationHelper
  def allow_manage_groups?
    policy(Group).index?
  end

  def allow_manage_ext_apps?
  	policy(Group).index?
  end

  def allow_manage_users?
  	policy(User).index?
  end
end

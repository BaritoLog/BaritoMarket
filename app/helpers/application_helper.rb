module ApplicationHelper
  def allow_manage_groups?
    policy(Group).index?
  end
end

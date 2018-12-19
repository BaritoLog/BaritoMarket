module AppGroupsHelper
  def max_tps(infrastructure)
    TPS_CONFIG[infrastructure.capacity]['max_tps']
  end

  def set_role_buttons(app_group_user, roles = {}, opts = {})
    current_role = app_group_user.role
    content_tag(:div, class: 'btn-group', role: 'group') do
      if roles[:member] != current_role
        concat link_to 'Set as Member', set_role_app_group_user_path(user_id: app_group_user.user_id, role_id: roles[:member], app_group_id: opts[:app_group_id]), class: 'btn btn-default', method: :patch
      end

      if roles[:admin] != current_role
        concat link_to 'Set as Admin', set_role_app_group_user_path(user_id: app_group_user.user_id, role_id: roles[:admin], app_group_id: opts[:app_group_id]), class: 'btn btn-default', method: :patch 
      end

      if roles[:owner] != current_role
        concat link_to 'Set as Owner', set_role_app_group_user_path(user_id: app_group_user.user_id, role_id: roles[:owner], app_group_id: opts[:app_group_id]), class: 'btn btn-default', method: :patch 
      end
    end
  end

  def allow_see_app_groups(app_group_id)
    app_group_ids = AppGroupUser.where(user: current_user).pluck(:app_group_id)
    app_group_ids.include?(app_group_id)
  end

  def allow_set_status(app_group_id)
    role_id = AppGroupRole.find_by(name: "owner")
    return true if AppGroupUser.find_by(user_id: current_user.id, app_group_id: app_group_id, role_id: role_id)
  end
end

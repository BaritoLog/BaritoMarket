module AppGroupsHelper
  def max_tps(infrastructure)
    infrastructure.component_template.try(:max_tps) || TPS_CONFIG[infrastructure.capacity]['max_tps']
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

  def show_apps(app_group_id)
    app_group = AppGroup.find(app_group_id)
    apps = []
    app_group.barito_apps.each do |app|
      apps << app.name
    end
    if apps == []
      "No app yet"
    else
      apps.join(", ").truncate(160, omission: '...')
    end
  end

  def show_apps_count(app_group_id)
    app_group = AppGroup.find(app_group_id)
    app_group.barito_apps.count
  end
end

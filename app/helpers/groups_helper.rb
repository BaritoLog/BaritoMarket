module GroupsHelper
  def set_group_role_buttons(group_user, roles = {}, opts = {})
    current_role = group_user.role
    puts opts
    content_tag(:div, class: 'btn-group', role: 'group') do
      if roles[:member] != current_role
        concat link_to 'Set as Member', set_role_group_user_path(user_id: group_user.user_id, role_id: roles[:member], group_id: opts[:group_id]), class: 'btn btn-default', method: :patch
      end

      if roles[:admin] != current_role
        concat link_to 'Set as Admin', set_role_group_user_path(user_id: group_user.user_id, role_id: roles[:admin], group_id: opts[:group_id]), class: 'btn btn-default', method: :patch 
      end

      if roles[:owner] != current_role
        concat link_to 'Set as Owner', set_role_group_user_path(user_id: group_user.user_id, role_id: roles[:owner], group_id: opts[:group_id]), class: 'btn btn-default', method: :patch 
      end
    end
  end
end

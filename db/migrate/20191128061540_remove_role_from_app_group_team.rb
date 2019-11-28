class RemoveRoleFromAppGroupTeam < ActiveRecord::Migration[5.2]
  def change
    remove_reference :app_group_teams, :role, foreign_key: { to_table: :app_group_roles }
  end
end

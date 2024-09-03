class AddMaxTpsToAppGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :max_tps, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE app_groups
          SET max_tps = helm_infrastructures.max_tps
          FROM helm_infrastructures
          WHERE helm_infrastructures.app_group_id = app_groups.id
        SQL
      end
    end
  end
end

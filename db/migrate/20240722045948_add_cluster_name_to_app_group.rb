class AddClusterNameToAppGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :cluster_name, :string

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE app_groups
          SET cluster_name = helm_infrastructures.cluster_name
          FROM helm_infrastructures
          WHERE helm_infrastructures.app_group_id = app_groups.id
        SQL
      end
    end
  end
end

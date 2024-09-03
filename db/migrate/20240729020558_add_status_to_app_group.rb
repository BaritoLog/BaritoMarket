class AddStatusToAppGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :app_groups, :status, :integer
    add_index :app_groups, :status

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE app_groups
          SET status = CASE
            WHEN EXISTS (
              SELECT 1
              FROM helm_infrastructures
              WHERE helm_infrastructures.app_group_id = app_groups.id
                AND helm_infrastructures.provisioning_status = 'DELETED'
            ) THEN 1
            ELSE 0
          END
        SQL
      end
    end
  end
end

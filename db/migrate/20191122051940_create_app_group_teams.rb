class CreateAppGroupTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :app_group_teams do |t|
      t.references :app_group, foreign_key: true
      t.references :group, foreign_key: true
      t.references :role, foreign_key: { to_table: :app_group_roles }
      t.timestamps
    end
  end
end

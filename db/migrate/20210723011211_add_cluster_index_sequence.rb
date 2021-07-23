class AddClusterIndexSequence < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE SEQUENCE cluster_index_seq;
      SELECT setval('cluster_index_seq', 1000 + 2 * (COUNT(*) + 1)) FROM infrastructures;
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE cluster_index_seq;
    SQL
  end
end

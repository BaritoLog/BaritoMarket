class AddClusterIndexSequence < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE SEQUENCE cluster_index_seq;
      SELECT setval('cluster_index_seq', 1000 + 4 * (COUNT(*) + 1)) FROM helm_infrastructures;
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE cluster_index_seq;
    SQL
  end
end

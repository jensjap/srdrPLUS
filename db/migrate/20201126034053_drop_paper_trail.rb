class DropPaperTrail < ActiveRecord::Migration[5.2]
  def up
    drop_table :versions
    drop_table :version_associations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

class DropExtractionChecksum < ActiveRecord::Migration[7.0]
  def up
    drop_table :extraction_checksums
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

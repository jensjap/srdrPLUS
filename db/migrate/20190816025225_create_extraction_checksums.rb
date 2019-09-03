class CreateExtractionChecksums < ActiveRecord::Migration[5.2]
  def change
    create_table :extraction_checksums do |t|
      t.references :extraction 
      t.string :hexdigest
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :extraction_checksums, :deleted_at
  end
end

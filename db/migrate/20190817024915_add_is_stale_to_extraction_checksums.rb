class AddIsStaleToExtractionChecksums < ActiveRecord::Migration[5.2]
  def change
    add_column :extraction_checksums, :is_stale, :boolean
  end
end

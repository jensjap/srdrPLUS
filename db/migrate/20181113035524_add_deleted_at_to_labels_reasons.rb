class AddDeletedAtToLabelsReasons < ActiveRecord::Migration[5.0]
  def change
    add_column :labels_reasons, :deleted_at, :datetime
    add_index :labels_reasons, :deleted_at
  end
end

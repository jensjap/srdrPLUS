class AddDeletedAtToFrequency < ActiveRecord::Migration[5.0]
  def change
    add_column :frequencies, :deleted_at, :datetime
    add_index :frequencies, :deleted_at
  end
end

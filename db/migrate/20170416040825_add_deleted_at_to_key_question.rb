class AddDeletedAtToKeyQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :key_questions, :deleted_at, :datetime
    add_index :key_questions, :deleted_at
  end
end

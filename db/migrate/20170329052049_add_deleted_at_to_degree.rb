class AddDeletedAtToDegree < ActiveRecord::Migration[5.0]
  def change
    add_column :degrees, :deleted_at, :datetime
    add_index :degrees, :deleted_at
  end
end

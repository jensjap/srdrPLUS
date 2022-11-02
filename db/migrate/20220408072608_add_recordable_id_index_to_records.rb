class AddRecordableIdIndexToRecords < ActiveRecord::Migration[5.2]
  def change
    add_index :records, :recordable_id
  end
end

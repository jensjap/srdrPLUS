class DropLabelsAndLabelsReasons < ActiveRecord::Migration[7.0]
  def change
    drop_table :labels_reasons if table_exists?(:labels_reasons)
    drop_table :labels if table_exists?(:labels)
  end
end

class RemoveLabelTypeIdFromReasons < ActiveRecord::Migration[7.0]
  def change
    remove_column :reasons, :label_type_id
  end
end

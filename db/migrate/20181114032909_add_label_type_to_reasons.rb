class AddLabelTypeToReasons < ActiveRecord::Migration[5.0]
  def change
    add_reference :reasons, :label_type, foreign_key: true
  end
end

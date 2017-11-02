class AddIndexToKeywords < ActiveRecord::Migration[5.0]
  def change
    add_index :keywords, :name, unique: true
  end
end

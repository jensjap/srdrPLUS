class RemoveIndexFromKeywords < ActiveRecord::Migration[5.0]
  def change
    remove_index :keywords, :name
  end
end
